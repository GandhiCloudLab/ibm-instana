#!/bin/bash

# Instana Setup Script for Flutter Todo App
# This script helps you set up Instana monitoring

echo "🔍 Instana Setup for Flutter Todo App"
echo "======================================"
echo ""

# Check if Instana key is provided
if [ -z "$1" ]; then
    echo "❌ Error: Instana key not provided"
    echo ""
    echo "Usage: ./scripts/setup_instana.sh YOUR_INSTANA_KEY YOUR_REPORTING_URL"
    echo ""
    echo "Example:"
    echo "  ./scripts/setup_instana.sh abc123xyz https://instana-backend.example.com"
    echo ""
    exit 1
fi

# Check if reporting URL is provided
if [ -z "$2" ]; then
    echo "❌ Error: Instana reporting URL not provided"
    echo ""
    echo "Usage: ./scripts/setup_instana.sh YOUR_INSTANA_KEY YOUR_REPORTING_URL"
    echo ""
    exit 1
fi

INSTANA_KEY=$1
INSTANA_URL=$2

echo "📝 Configuration:"
echo "  Key: ${INSTANA_KEY:0:10}..."
echo "  URL: $INSTANA_URL"
echo ""

# Update pubspec.yaml
echo "📦 Adding Instana dependency to pubspec.yaml..."
if grep -q "instana_agent:" pubspec.yaml; then
    echo "  ✅ Instana agent already in pubspec.yaml"
else
    echo "  instana_agent: ^4.0.0" >> pubspec.yaml
    echo "  ✅ Added instana_agent to pubspec.yaml"
fi

# Install dependencies
echo ""
echo "📥 Installing dependencies..."
flutter pub get

# Update config file
echo ""
echo "⚙️  Updating Instana configuration..."
sed -i.bak "s/YOUR_INSTANA_KEY_HERE/$INSTANA_KEY/g" lib/config/instana_config.dart
sed -i.bak "s|https://your-instana-backend.com|$INSTANA_URL|g" lib/config/instana_config.dart
rm lib/config/instana_config.dart.bak

echo "  ✅ Configuration updated"

# Create .env file for reference
echo ""
echo "📄 Creating .env file..."
cat > .env << EOF
# Instana Configuration
INSTANA_KEY=$INSTANA_KEY
INSTANA_URL=$INSTANA_URL

# To use these in Flutter, run:
# flutter run --dart-define=INSTANA_KEY=\$INSTANA_KEY --dart-define=INSTANA_URL=\$INSTANA_URL
EOF

echo "  ✅ .env file created"

# Add .env to .gitignore
echo ""
echo "🔒 Adding .env to .gitignore..."
if grep -q ".env" .gitignore 2>/dev/null; then
    echo "  ✅ .env already in .gitignore"
else
    echo ".env" >> .gitignore
    echo "  ✅ Added .env to .gitignore"
fi

echo ""
echo "✅ Instana setup complete!"
echo ""
echo "📚 Next steps:"
echo "  1. Review lib/config/instana_config.dart"
echo "  2. Check docs/INSTANA_SETUP.md for integration guide"
echo "  3. Run the app: flutter run"
echo "  4. Verify data in Instana dashboard"
echo ""
echo "🚀 To run with environment variables:"
echo "  flutter run --dart-define=INSTANA_KEY=$INSTANA_KEY --dart-define=INSTANA_URL=$INSTANA_URL"
echo ""

# Made with Bob
