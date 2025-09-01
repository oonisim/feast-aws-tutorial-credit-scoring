#!/usr/bin/env bash
set -e
#--------------------------------------------------------------------------------
# Setup account for the FEAST operations
#--------------------------------------------------------------------------------
GID="2000"
GROUPNAME="feast"
USERNAME="feast"
SUDOERS_FILE="/etc/sudoers.d/${USERNAME}"

#--------------------------------------------------------------------------------
# Create FEAST Account
#--------------------------------------------------------------------------------
echo "Creating account for ${USERNAME}..."
sudo groupadd -g "${GID}" "${GROUPNAME}"
sudo useradd -g "${GROUPNAME}" -m -s /bin/bash "${USERNAME}"

#--------------------------------------------------------------------------------
# Create the sudoers file with NOPASSWD permissions
#--------------------------------------------------------------------------------
echo "Creating sudoers file for user: ${USERNAME}..."
sudo tee "${SUDOERS_FILE}" > /dev/null <<EOF
# Sudoers configuration for feast user
# Created on $(date)
# Full sudo access without password
${USERNAME} ALL=(ALL) NOPASSWD:ALL
EOF

# Set correct permissions (440 - read-only for owner and group)
sudo chmod 440 "${SUDOERS_FILE}"
sudo chown root:root "${SUDOERS_FILE}"

# Validate the sudoers file syntax
if sudo visudo -c -f "$SUDOERS_FILE"; then
    echo "✅ Sudoers file created successfully: $SUDOERS_FILE"
    echo "✅ Syntax validation passed"

    # Display the contents
    echo "📄 File contents:"
    sudo cat "$SUDOERS_FILE"

    # Test if user exists
    if id "$USERNAME" &>/dev/null; then
        echo "✅ User '$USERNAME' exists"
        echo "🔑 User '$USERNAME' now has passwordless sudo access"
    else
        echo "⚠️  Warning: User '$USERNAME' does not exist yet"
        echo "   Create the user with: sudo adduser $USERNAME"
    fi
else
    echo "❌ Error: Sudoers file syntax validation failed"
    echo "   Removing invalid file..."
    sudo rm -f "$SUDOERS_FILE"
    exit 1
fi
