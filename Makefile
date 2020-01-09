.PHONY:build all clean test

setup:
	@echo "Setting up..."

	@echo "  Checking if config.sh exists, if not creating it..."
	@cp --no-clobber example.config.sh config.sh

	@echo "  Installing dependencies..."
	yay -S --needed --noconfirm qemu qemu-user-static-bin parted dosfstools
	@echo "  Enabling systemd-binfmt..."
	sudo systemctl enable --now systemd-binfmt

	@echo "Setup complete"

builder:
	@echo "Building custom arm image..."
	bash build.sh
	@echo "Build completed successfully"

clean:
	@echo "Running cleanup..."
	@bash clean.sh
	@echo "Cleanup completed"

build: builder clean

