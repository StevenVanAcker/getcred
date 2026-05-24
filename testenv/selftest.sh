#!/bin/sh -e

# self test for bw, bw-login-and-unlock, and getcred.
echo "Bitwarden CLI version:"
bw sdk-version

echo "Testing bw-login-and-unlock script..."
bw-login-and-unlock