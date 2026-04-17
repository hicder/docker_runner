# vLLM Development Docker Image

This Dockerfile creates a development environment for vLLM with ROCm support.

## Base Image

Uses `rocm/vllm-dev:base` as the base, which includes:
- ROCm 7.2.1
- Python 3.12
- PyTorch, Triton, FlashAttention, AITER (pre-built for ROCm)
- All vLLM dependencies

## Features

- **SSH Server**: For remote development
- **Development Tools**: neovim, zsh, tmux, git, cmake, ninja
- **Package Management**: UV for fast Python package operations
- **Languages**: Python, Rust, Go
- **AI Assistant**: opencode-ai via Bun
- **Build Tools**: All dependencies for building vLLM from source
- **ROCm Environment**: Fully configured for AMD GPU development

## Build Arguments

- `user`: Username (default from docker_runner)
- `user_id`: User ID (default from docker_runner)
- `group`: Group name (default from docker_runner)
- `group_id`: Group ID (default from docker_runner)

## Usage

```bash
# Build the image
docker build \
  --build-arg user=$(whoami) \
  --build-arg user_id=$(id -u) \
  --build-arg group=$(id -gn) \
  --build-arg group_id=$(id -g) \
  -t docker_runner_vllm:latest \
  -f docker/vllm/Dockerfile .

# Run with GPU access
docker run -it --gpus all \
  -p 2222:22 \
  -v $(pwd):/opt/src \
  docker_runner_vllm:latest
```

## Environment Variables

Key ROCm environment variables are pre-configured:
- `ROCM_PATH=/opt/rocm`
- `PYTORCH_ROCM_ARCH`: Supports gfx90a, gfx942, gfx950, gfx1100, gfx1101, gfx1200, gfx1201, gfx1150, gfx1151
- `HSA_NO_SCRATCH_RECLAIM=1` (required for RCCL)

## Development Workflow

1. SSH into the container: `ssh -p 2222 <user>@localhost`
2. vLLM source code can be mounted at `/opt/src`
3. Build vLLM: `cd /opt/src && pip install -e .`
4. Use `uv` for fast package operations
5. Use `opencode` for AI-assisted development
