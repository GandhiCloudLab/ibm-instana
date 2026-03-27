"""
Instana Configuration for FastAPI Backend

This configuration is for Instana SaaS-based monitoring.
The Instana agent should be installed and running on your system or container.

For SaaS setup:
1. Install Instana agent on your host/container
2. Configure agent with your Instana backend URL and agent key
3. The Python sensor will automatically connect to the local agent
"""

import os
from typing import Optional


class InstanaConfig:
    """Instana monitoring configuration for FastAPI backend"""
    
    # Service identification
    SERVICE_NAME = os.getenv('INSTANA_SERVICE_NAME', 'todo-api-backend')
    
    # Enable/disable Instana monitoring
    # Set to 'false' in development if you don't have Instana agent running
    ENABLED = os.getenv('INSTANA_ENABLED', 'true').lower() == 'true'
    
    # Instana agent connection (for SaaS)
    # The Python sensor connects to the local Instana agent
    # which then forwards data to Instana SaaS backend
    AGENT_HOST = os.getenv('INSTANA_AGENT_HOST', 'localhost')
    AGENT_PORT = int(os.getenv('INSTANA_AGENT_PORT', '42699'))
    
    # Log level for Instana sensor
    LOG_LEVEL = os.getenv('INSTANA_LOG_LEVEL', 'INFO')
    
    # Additional tags for service identification
    TAGS = {
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'version': '1.0.0',
        'component': 'backend-api',
        'technology': 'fastapi-python'
    }
    
    @classmethod
    def get_config_summary(cls) -> dict:
        """Get configuration summary for logging"""
        return {
            'enabled': cls.ENABLED,
            'service_name': cls.SERVICE_NAME,
            'agent_host': cls.AGENT_HOST,
            'agent_port': cls.AGENT_PORT,
            'environment': cls.TAGS['environment']
        }
    
    @classmethod
    def is_agent_available(cls) -> bool:
        """Check if Instana agent is available"""
        if not cls.ENABLED:
            return False
        
        try:
            import socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex((cls.AGENT_HOST, cls.AGENT_PORT))
            sock.close()
            return result == 0
        except Exception:
            return False


# Environment variable configuration guide
"""
To configure Instana for your environment, set these environment variables:

# Required for SaaS
export INSTANA_SERVICE_NAME="todo-api-backend"
export INSTANA_ENABLED="true"

# Optional (defaults shown)
export INSTANA_AGENT_HOST="localhost"
export INSTANA_AGENT_PORT="42699"
export INSTANA_LOG_LEVEL="INFO"
export ENVIRONMENT="production"

# For development without Instana agent
export INSTANA_ENABLED="false"
"""

# Made with Bob
