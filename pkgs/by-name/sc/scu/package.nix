{ lib
, stdenv
, fetchFromGitLab
, rustPlatform
, fetchpatch
, darwin
}:
rustPlatform.buildRustPackage {
  pname = "scu";
  version = "1.5.1";

  srcs = [
    (fetchFromGitLab {
      owner = "omnitix";
      repo = "scu";
      rev = "0d7ac8a23746da3e3bdeb852f635707b1dc06a89";
      hash = "sha256-yfAbw80iBcw0ybhKWLwr+Eve6JFFSz62XBiQKvxjDmc=";
    })
    (fetchFromGitLab {
      name = "libscu";
      owner = "omnitix";
      repo = "libscu";
      rev = "381a4c5f2b9e34d785068ea5bf132013882e4453";
      hash = "sha256-8d4OIOzxMnMm7EYwuuv/hMGNqRXxfHd+pUxMZGV67ME=";
    })
  ];

  unpackPhase = ''
    runHook preUnpack

    cp -R "$(printf '%s' "$srcs" | cut -d ' ' -f 1)" source
    chmod -R u+w source
    for src in $(printf '%s' "$srcs" | cut -d ' ' -f 2-); do
      cp -R "$src" source/"$(stripHash "$src")"
    done
    chmod -R u+w source

    runHook postUnpack
  '';

  sourceRoot = "source";

  patches = [
    (fetchpatch {
      url = "https://gitlab.com/omnitix/libscu/-/merge_requests/1.patch";
      stripLen = 1;
      extraPrefix = "libscu/";
      hash = "sha256-BLg7tzvaDLbvgWpOOg4JY8+3lHnMmnCDig+xXlx+oq0=";
    })
  ];

  cargoPatches = [
    (fetchpatch {
      url = "https://gitlab.com/omnitix/scu/-/merge_requests/6.patch";
      hash = "sha256-LNAM/ppESv9VX1MLwgSDd00nAOsirlMCecnze0VANKM=";
    })
    ./libscu.patch
  ];
  cargoHash = "sha256-dEn+mPO7fz8T5uiEQOvN2mKvhU6Wb6MExzswlNy6wBE=";

  buildInputs = lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.IOKit;

  meta = {
    description = "Command-line system fetch utility written in Rust";
    license = lib.licenses.gpl3Plus;
    mainProgram = "scu";
    maintainers = with lib.maintainers; [ caralice ];
  };
}
