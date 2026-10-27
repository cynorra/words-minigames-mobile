#!/bin/bash

# Quicko App Build Script
# This script helps build the app with different configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --platform PLATFORM    Target platform (android, ios, web)"
    echo "  -e, --environment ENV      Environment (development, production)"
    echo "  -t, --type TYPE            Build type (debug, release, profile)"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -p android -e development -t debug"
    echo "  $0 -p ios -e production -t release"
    echo "  $0 -p web -e development -t debug"
}

# Default values
PLATFORM=""
ENVIRONMENT="production"
BUILD_TYPE="release"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate platform
if [[ -z "$PLATFORM" ]]; then
    print_error "Platform is required"
    show_usage
    exit 1
fi

# Validate environment
if [[ "$ENVIRONMENT" != "development" && "$ENVIRONMENT" != "production" ]]; then
    print_error "Environment must be 'development' or 'production'"
    exit 1
fi

# Validate build type
if [[ "$BUILD_TYPE" != "debug" && "$BUILD_TYPE" != "release" && "$BUILD_TYPE" != "profile" ]]; then
    print_error "Build type must be 'debug', 'release', or 'profile'"
    exit 1
fi

print_info "Building Quicko App..."
print_info "Platform: $PLATFORM"
print_info "Environment: $ENVIRONMENT"
print_info "Build Type: $BUILD_TYPE"

# Set environment variables based on environment
if [[ "$ENVIRONMENT" == "development" ]]; then
    print_info "Using development configuration..."
    export ENVIRONMENT="development"
    # Use test AdMob IDs for development
    export ANDROID_APP_ID="ca-app-pub-3940256099942544~3347511713"
    export ANDROID_REWARDED_AD_ID="ca-app-pub-3940256099942544/5224354917"
    export ANDROID_BANNER_AD_ID="ca-app-pub-3940256099942544/6300978111"
    export ANDROID_LEADERBOARD_BANNER_AD_ID="ca-app-pub-3940256099942544/6300978111"
    export ANDROID_INTERSTITIAL_AD_ID="ca-app-pub-3940256099942544/1033173712"
    export IOS_APP_ID="ca-app-pub-3940256099942544~1458002511"
    export IOS_REWARDED_AD_ID="ca-app-pub-3940256099942544/1712485313"
    export IOS_BANNER_AD_ID="ca-app-pub-3940256099942544/2934735716"
    export IOS_LEADERBOARD_BANNER_AD_ID="ca-app-pub-3940256099942544/2934735716"
else
    print_info "Using production configuration..."
    export ENVIRONMENT="production"
    # Use production AdMob IDs
    export ANDROID_APP_ID="ca-app-pub-4674211063760769~4701909672"
    export ANDROID_REWARDED_AD_ID="ca-app-pub-4674211063760769/7822897035"
    export ANDROID_BANNER_AD_ID="ca-app-pub-4674211063760769/8014468725"
    export ANDROID_LEADERBOARD_BANNER_AD_ID="ca-app-pub-4674211063760769/1863993345"
    export ANDROID_INTERSTITIAL_AD_ID="ca-app-pub-4674211063760769/2075746330"
    export IOS_APP_ID="ca-app-pub-4674211063760769~4966644738"
    export IOS_REWARDED_AD_ID="ca-app-pub-4674211063760769/7555496667"
    export IOS_BANNER_AD_ID="ca-app-pub-4674211063760769/9584879730"
    export IOS_LEADERBOARD_BANNER_AD_ID="ca-app-pub-4674211063760769/2173293578"
fi

# Build command based on platform
case $PLATFORM in
    android)
        print_info "Building for Android..."
        if [[ "$BUILD_TYPE" == "release" ]]; then
            flutter build apk --release \
                --dart-define=ENVIRONMENT="$ENVIRONMENT" \
                --dart-define=ANDROID_APP_ID="$ANDROID_APP_ID" \
                --dart-define=ANDROID_REWARDED_AD_ID="$ANDROID_REWARDED_AD_ID" \
                --dart-define=ANDROID_BANNER_AD_ID="$ANDROID_BANNER_AD_ID" \
                --dart-define=ANDROID_LEADERBOARD_BANNER_AD_ID="$ANDROID_LEADERBOARD_BANNER_AD_ID"
        elif [[ "$BUILD_TYPE" == "debug" ]]; then
            flutter build apk --debug \
                --dart-define=ENVIRONMENT="$ENVIRONMENT" \
                --dart-define=ANDROID_APP_ID="$ANDROID_APP_ID" \
                --dart-define=ANDROID_REWARDED_AD_ID="$ANDROID_REWARDED_AD_ID" \
                --dart-define=ANDROID_BANNER_AD_ID="$ANDROID_BANNER_AD_ID" \
                --dart-define=ANDROID_LEADERBOARD_BANNER_AD_ID="$ANDROID_LEADERBOARD_BANNER_AD_ID"
        else
            flutter build apk --profile \
                --dart-define=ENVIRONMENT="$ENVIRONMENT" \
                --dart-define=ANDROID_APP_ID="$ANDROID_APP_ID" \
                --dart-define=ANDROID_REWARDED_AD_ID="$ANDROID_REWARDED_AD_ID" \
                --dart-define=ANDROID_BANNER_AD_ID="$ANDROID_BANNER_AD_ID" \
                --dart-define=ANDROID_LEADERBOARD_BANNER_AD_ID="$ANDROID_LEADERBOARD_BANNER_AD_ID"
        fi
        ;;
    ios)
        print_info "Building for iOS..."
        if [[ "$BUILD_TYPE" == "release" ]]; then
            flutter build ios --release \
                --dart-define=ENVIRONMENT="$ENVIRONMENT" \
                --dart-define=IOS_APP_ID="$IOS_APP_ID" \
                --dart-define=IOS_REWARDED_AD_ID="$IOS_REWARDED_AD_ID" \
                --dart-define=IOS_BANNER_AD_ID="$IOS_BANNER_AD_ID" \
                --dart-define=IOS_LEADERBOARD_BANNER_AD_ID="$IOS_LEADERBOARD_BANNER_AD_ID"
        elif [[ "$BUILD_TYPE" == "debug" ]]; then
            flutter build ios --debug \
                --dart-define=ENVIRONMENT="$ENVIRONMENT" \
                --dart-define=IOS_APP_ID="$IOS_APP_ID" \
                --dart-define=IOS_REWARDED_AD_ID="$IOS_REWARDED_AD_ID" \
                --dart-define=IOS_BANNER_AD_ID="$IOS_BANNER_AD_ID" \
                --dart-define=IOS_LEADERBOARD_BANNER_AD_ID="$IOS_LEADERBOARD_BANNER_AD_ID"
        else
            flutter build ios --profile \
                --dart-define=ENVIRONMENT="$ENVIRONMENT" \
                --dart-define=IOS_APP_ID="$IOS_APP_ID" \
                --dart-define=IOS_REWARDED_AD_ID="$IOS_REWARDED_AD_ID" \
                --dart-define=IOS_BANNER_AD_ID="$IOS_BANNER_AD_ID" \
                --dart-define=IOS_LEADERBOARD_BANNER_AD_ID="$IOS_LEADERBOARD_BANNER_AD_ID"
        fi
        ;;
    web)
        print_info "Building for Web..."
        if [[ "$BUILD_TYPE" == "release" ]]; then
            flutter build web --release \
                --dart-define=ENVIRONMENT="$ENVIRONMENT"
        elif [[ "$BUILD_TYPE" == "debug" ]]; then
            flutter build web --debug \
                --dart-define=ENVIRONMENT="$ENVIRONMENT"
        else
            flutter build web --profile \
                --dart-define=ENVIRONMENT="$ENVIRONMENT"
        fi
        ;;
    *)
        print_error "Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

print_success "Build completed successfully!"
print_info "Build type: $BUILD_TYPE"
print_info "Environment: $ENVIRONMENT"
print_info "Platform: $PLATFORM"
