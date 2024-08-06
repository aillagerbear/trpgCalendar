#!/bin/sh

mkdir -p assets

echo "SUPABASE_URL=$SUPABASE_URL" > assets/.env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> assets/.env
