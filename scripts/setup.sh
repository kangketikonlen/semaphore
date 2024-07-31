#!/bin/sh

# Create SSH directory
mkdir -p /home/semaphore/.ssh || {
    echo "Failed to create SSH directory"
    exit 1
}

# Configure SSH
echo "StrictHostKeyChecking no" >/home/semaphore/.ssh/config || {
    echo "Failed to configure SSH"
    exit 1
}

# Set permissions
chmod 700 /home/semaphore/.ssh || {
    echo "Failed to set permissions for SSH directory"
    exit 1
}
chmod 600 /home/semaphore/.ssh/config || {
    echo "Failed to set permissions for SSH config"
    exit 1
}

# Check if SSH key pair exists
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    # Generate SSH key pair without passphrase
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N '' || {
        echo "Failed to generate SSH key pair"
        exit 1
    }
fi

# Fetch remote id_rsa.pub
if [ ! -f "/tmp/keys/key.pub" ]; then
    mkdir -p "/tmp/keys" || {
        echo "Failed to create directory for key"
        exit 1
    }
    scp "/home/semaphore/.ssh/id_rsa.pub" "/tmp/keys/key.pub" || {
        echo "Failed to fetch remote id_rsa.pub"
        exit 1
    }
fi

# Add SSH key to GitHub
curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"title":"Semaphore Docker","key":"'"$(cat /tmp/keys/key.pub)"'"}' \
    "https://api.github.com/user/keys" || {
    echo "Failed to add SSH key to GitHub"
    exit 1
}

echo "SSH key added successfully to GitHub"
