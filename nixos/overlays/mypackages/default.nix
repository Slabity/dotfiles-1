self: super:

{
  nix-review = self.stdenv.mkDerivation {
    name = "nix-review";
    src = ./nix-review;
    buildInputs = [ self.python3 ];
    installPhase = ''
      runHook preInstall
      install -m755 -D review.py $out/bin/nix-review
      runHook postInstall
    '';
  };

  hplip = super.hplip.override { withPlugin = true; };

  mosh = super.mosh.overrideDerivation (old: {
    name = "mosh-ssh-agent";
    src = self.pkgs.fetchFromGitHub {
      owner = "mobile-shell";
      repo = "mosh";
      rev = "968f3ccba04faf3a5b12d583128ce7450b006742";
      sha256 = "1dyraknc9wwfb097ixryzjj86d60zz4yi0av0fq07p3bjz8f1sd9";
    };
  });

  #neovim = pkgs.neovim.override {
  #  vimAlias = true;
  #  extraPythonPackages = with python27Packages; [jedi];
  #  #python3Packages = python36Packages;
  #  extraPython3Packages = with python3Packages; [jedi requests2];
  #};

  #nixUnstable = super.nixUnstable.overrideDerivation (old: {
  #  src = self.fetchFromGitHub {
  #    owner = "NixOS";
  #    repo = "nix";
  #    rev = "c7654bc491d9ce7c1fbadecd7769418fa79a2060";
  #    sha256 = "11djnvf2dg5qssix34n5avq1b334lhcbffissxghzfa3kvsm0x9d";
  #  };
  #  buildInputs = old.buildInputs ++ [ self.gperftools self.gcc7 self.nlohmann_json ];
  #  CXXFLAGS = "-flto -march=native -O3";
  #  CFLAGS = "-flto -march=native -O3";
  #  NIX_LDFLAGS = "-ltcmalloc";
  #  enableParallelBuilding = true;
  #}) // { inherit (super.nixUnstable) perl-bindings; };

  #mysystemd = self.callPackage ./systemd.nix {};

  networkd = super.stdenv.mkDerivation {
    name = "systemd-networkd";
    buildInputs = with self; [
      linuxHeaders pkgconfig intltool gperf libcap kmod
      xz pam acl
      libuuid m4 glib libxslt libgcrypt libgpgerror
      libmicrohttpd kexectools libseccomp libffi audit lz4 libapparmor
      iptables gnu-efi
      gettext docbook_xsl docbook_xml_dtd_42 docbook_xml_dtd_45
      (python3.withPackages (pythonPackages: with pythonPackages; [ lxml ]))
      patchelf
    ];
    nativeBuildInputs = with self; [ meson ninja glibcLocales ];
    src = self.fetchFromGitHub {
      owner = "Mic92";
      repo = "systemd";
      rev = "9f11187dae637c3184922276dd809a0ebcb9cb69";
      sha256 = "05nknky9ga2spfmid6gwplinn0iyc7rm63dxj7fmnb8yxdywqq1q";
    };
    LC_ALL="en_US.utf8";

    configurePhase = ''
      patchShebangs .
      substituteInPlace src/network/networkd-manager.c \
        --replace /usr/lib/systemd/network $out/lib/systemd/network
      meson -D system-uid-max=499 -D system-gid-max=499 . build
      cd build
      '';
    buildPhase = "ninja systemd-networkd";
    installPhase = ''
      mkdir -p $out/{bin,lib/systemd}
      cp src/shared/libsystemd-shared-*.so $out/lib
      cp -r ../network $out/lib/systemd/network
      cp ./systemd-networkd $out/bin
      patchelf --set-rpath "$out/lib:\$ORIGIN" $out/bin/systemd-networkd
    '';
  };

  ocaml_with_topfind = with self; self.stdenv.mkDerivation rec {
    name = "ocaml_with_topfind-${version}";
    version = lib.getVersion ocaml;

    nativeBuildInputs = [ makeWrapper ];
    buildCommand = ''
      makeWrapper "${ocaml}/bin/ocaml" "$out/bin/ocaml_topfind" \
      --add-flags "-I ${ocamlPackages.findlib}/lib/ocaml/${version}/site-lib"
      '';
  };
}