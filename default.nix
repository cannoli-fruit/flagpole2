{ stdenv, makeWrapper ? null, writeShellScriptBin ? null }:

stdenv.mkDerivation rec {
  pname = "flagpole";
  version = "1.0"; # bump as needed

  src = ./.;

  nativeBuildInputs = [];
  buildInputs = [];

  # If you want wrapper helpers (optional)
  propagatedBuildInputs = [];

  installPhase = ''
    mkdir -p $out/lib/flagpole
    cp ${src}/setup.ll $out/lib/flagpole/setup.ll
    cp ${src}/end.ll $out/lib/flagpole/end.ll
    mkdir -p $out/lib/flagpole/lib
    cp -r ${src}/lib/* $out/lib/flagpole/
    cp ${src}/llvm.py $out/lib/flagpole/fpcc
    chmod +x $out/lib/flagpole/fpcc

    mkdir -p $out/bin
    cp ${src}/compiler.sh $out/bin/fpc
    chmod +x $out/bin/fpc
  '';

  meta = with stdenv.lib; {
    description = "Flagpole compiler";
    license = licenses.gpl3;
    maintainers = with maintainers; [];
  };
}
