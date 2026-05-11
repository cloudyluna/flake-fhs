{
  description = ''
    A nix flake for setting up Linux's File Hierarchy System (FHS) environment.
    This enables user to download a pre-compiled executables, compiled from other
    Linux systems and run them as if they were natively produced on here.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        fhs = pkgs.buildFHSEnv {
          name = "flake-fhs";
          targetPkgs = (
            let
              xPackages = with pkgs; [
                libx11
                libxcursor
                libxcomposite
                libxdamage
                libxxf86vm
                libxext
                libxfixes
                libxrandr
                libxrender
                libxcb
                libxinerama
                libxi
              ];

              sdlPackages = with pkgs; [
                SDL
                SDL_gfx
                SDL_image
                SDL_mixer
                SDL_ttf
                SDL2
                SDL2_gfx
                SDL2_image
                SDL2_mixer
                SDL2_ttf
              ];

              commonPackages = with pkgs; [
                cmake
                automake
                autoconf
                gnumake
                pkg-config
                vulkan-loader
                wayland
                openssl
                libtinfo
                ncurses
                clang
                lldb
                valgrind
                libxkbcommon
                libdrm
                dbus
                gmp
                nss
                libpng
                zlib
                libGL
                libGLU

                gst_all_1.gstreamer
                gst_all_1.gst-plugins-base
                gst_all_1.gst-plugins-good
                gst_all_1.gst-plugins-bad
                gst_all_1.gst-plugins-ugly
                fontconfig
                glib
                gobject-introspection
              ];
            in
            pkgs': xPackages ++ commonPackages ++ sdlPackages
          );

          multiPkgs =
            pkgs':
            (with pkgs; [
              udev
              alsa-lib
            ]);

          runScript = "bash";
        };

      in
      {
        devShells.default = fhs.env;
        packages.default = fhs;
      }
    );
}
