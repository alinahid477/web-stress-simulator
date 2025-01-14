#!/bin/bash

set -e

BUILD_VERSION=1.0.0

echo "Building web-stress-simulator $BUILD_VERSION..."

docker build -t alinahid477/web-stress-simulator:$BUILD_VERSION .

echo "Finished building web-stress-simulator."
