#!/bin/sh

# Build the Flutter web project
flutter build web

# Switch to gh-pages branch
git checkout gh-pages

# Copy the web build files to the root
cp -R build/web/* .

# Add and commit changes
git add .
git commit -m "Deploy to GitHub Pages"

# Push to the gh-pages branch
git push origin gh-pages

# Switch back to main branch
git checkout main
