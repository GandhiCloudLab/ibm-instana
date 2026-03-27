from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes.todos import router as todos_router
from instana_config import InstanaConfig
import sys

# Initialize Instana monitoring (SaaS-based)
# Must be done before creating FastAPI app for proper instrumentation
instana_initialized = False
if InstanaConfig.ENABLED:
    try:
        import os
        
        # CRITICAL: Set environment variables BEFORE importing instana
        # The Instana sensor reads these on import
        os.environ['INSTANA_SERVICE_NAME'] = InstanaConfig.SERVICE_NAME
        os.environ['INSTANA_AGENT_HOST'] = InstanaConfig.AGENT_HOST
        os.environ['INSTANA_AGENT_PORT'] = str(InstanaConfig.AGENT_PORT)
        os.environ['INSTANA_LOG_LEVEL'] = InstanaConfig.LOG_LEVEL
        
        # Add custom tags via environment variables
        tags_list = [f"{key}={value}" for key, value in InstanaConfig.TAGS.items()]
        os.environ['INSTANA_TAGS'] = ','.join(tags_list)
        
        # Check if agent is available
        agent_available = InstanaConfig.is_agent_available()
        
        if agent_available:
            # NOW import instana after env vars are set
            import instana
            
            # The Instana sensor auto-instruments FastAPI when imported
            # We just need to verify it loaded successfully
            instana_initialized = True
            print("=" * 60)
            print("✅ Instana Monitoring Initialized (SaaS)")
            print(f"   Service: {InstanaConfig.SERVICE_NAME}")
            print(f"   Agent: {InstanaConfig.AGENT_HOST}:{InstanaConfig.AGENT_PORT}")
            print(f"   Environment: {InstanaConfig.TAGS['environment']}")
            print(f"   Auto-instrumentation: Enabled")
            print("=" * 60)
        else:
            print("=" * 60)
            print(f"⚠️  WARNING: Instana agent not available at {InstanaConfig.AGENT_HOST}:{InstanaConfig.AGENT_PORT}")
            print("   The agent may still be starting up. Wait a moment and restart the backend.")
            print("   Monitoring is disabled but API will work normally.")
            print("")
            print("   To check agent status:")
            print("   - docker logs instana-agent")
            print("   - docker exec instana-agent netstat -tlnp | grep 42699")
            print("=" * 60)
        
    except ImportError:
        print("⚠️  Instana package not installed. Run: pip install instana")
        print("   Continuing without monitoring...")
    except Exception as e:
        print(f"⚠️  Instana initialization failed: {e}")
        print("   Continuing without monitoring...")
else:
    print("ℹ️  Instana monitoring is disabled (INSTANA_ENABLED=false)")

# Create FastAPI app
app = FastAPI(
    title="Todo API",
    description="RESTful API for Flutter Todo App with in-memory database and Instana monitoring",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS for Flutter web and mobile apps
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(todos_router)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Todo API Server with Instana Monitoring",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health",
        "monitoring": "instana-saas" if instana_initialized else "disabled"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    monitoring_status = "enabled" if instana_initialized else "disabled"
    agent_available = InstanaConfig.is_agent_available() if InstanaConfig.ENABLED else False
    
    return {
        "status": "healthy",
        "service": "todo-api",
        "database": "in-memory",
        "monitoring": {
            "provider": "instana-saas",
            "status": monitoring_status,
            "agent_connected": agent_available,
            "service_name": InstanaConfig.SERVICE_NAME if InstanaConfig.ENABLED else None
        }
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )

# Made with Bob
