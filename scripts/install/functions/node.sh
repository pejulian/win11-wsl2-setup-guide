#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Installing NVM"

curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh" | bash

# Load nvm in current shell for this setup
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

for version in "${NODE_VERSIONS[@]}"; do
    echo "🔧 Installing nodejs $version"
    nvm install "$version"
done

# Set default node version
echo "🔧 Setting default node version to 20"
nvm alias default 20 

echo "🔧 Node version: $(node -v)"
echo "🔧 NPM version: $(npm -v)"
echo "🎉 Installed NVM with version: $(nvm --version)"

if [ -f "$ZSHRC_FILE" ]; then
    echo "🔧 Adding zsh-hook for load-nvmrc"
    add_block_if_missing "$NVM_HOOK_BLOCK" "$ZSHRC_FILE"
fi

echo "⚙ Configuring NPM"

if [ -f "$ZSHRC_FILE" ]; then
    echo "🔧 Adding NPM config to $ZSHRC_FILE"
    add_block_if_missing "$NPM_CONFIG_BLOCK" "$ZSHRC_FILE"
fi

if command -v npm >/dev/null 2>&1; then
    echo "🔧 Installing node-gyp"
    npm i -g node-gyp >/dev/null 2>&1 || echo "🤯 Failed to install node-gyp" 
    if command -v node-gyp >/dev/null 2>&1; then
        echo "🔧 node-gyp installed to $(which node-gyp)"
        echo "🎉 Installed node-gyp with version: $(node-gyp --version)"

        echo "🔧 Testing node-gyp installation"
        current_pwd=$(pwd)

        cd "$HOME"

        if [ -d "$HOME/node-gyp-test" ]; then
            rm -rf "$HOME/node-gyp-test"
        fi

        mkdir node-gyp-test && cd node-gyp-test

        npm init -y 
        npm install nan

        echo "🔧 Creating binding.gyp and hello.cpp"
        tee binding.gyp > /dev/null <<'EOF'
        {
            "targets": [
                {
                    "target_name": "hello",
                    "sources": [ "hello.cpp" ],
                    "cflags_cc": ["-Wno-cast-function-type"],
                    "include_dirs": [
                        "<!(node -e \"require('nan')\")"
                    ]
                }
            ]
        }
EOF
        tee hello.cpp > /dev/null <<'EOF'
        #include <nan.h>

        void Method(const Nan::FunctionCallbackInfo<v8::Value>& info) {
          info.GetReturnValue().Set(Nan::New("world").ToLocalChecked());
        }

        NAN_MODULE_INIT(Init) {
          Nan::Set(target, Nan::New("hello").ToLocalChecked(),
            Nan::GetFunction(Nan::New<v8::FunctionTemplate>(Method)).ToLocalChecked());
        }

        NODE_MODULE(hello, Init)
EOF

        echo "🔧 Running node-gyp configure build"
        node-gyp configure build

        tee test.js > /dev/null <<'EOF'
        const addon = require('./build/Release/hello');
        console.log('Hello ' + addon.hello());
EOF
        
        echo "🔧 Running test.js"
        output=$(node test.js)
        expected="Hello world"

        if [[ $output == *"$expected"* ]]; then
            echo "🎉 node-gyp test succeeded"
        else
            echo "🤯 node-gyp test failed"
        fi

        cd "$current_pwd"

        rm -rf "$HOME/node-gyp-test"
    else
        echo "🤯 Failed to install node-gyp"
    fi
else
    echo "🤯 npm is not installed. Skipping package installation."
fi

echo "✅ NPM configured"
