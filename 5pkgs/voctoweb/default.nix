{ stdenv, bundlerEnv, fetchFromGitHub, ruby, nodejs }:
let
  env = bundlerEnv {
    name = "voctoweb";
    inherit ruby;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
  };
in
stdenv.mkDerivation {
  name = "voctoweb-2020-11-29";

  src = fetchFromGitHub {
    owner = "voc";
    repo = "voctoweb";
    rev = "21da70f6c532520394caedcb79aaddf7b4150bb0";
    sha256 = "171fkpqmzrnrbf67dfkfnmwmq0q40hg57vrq0yqf7m6fk1yn7dfz";
  };

  buildInputs = [ env nodejs ];

  buildPhase = ''
    cp config/database.yml.template config/database.yml
    cp config/settings.yml.template config/settings.yml
    cp .env.development .env.production
    bundler exec rake assets:precompile RAILS_ENV=production
    rm .env.production
  '';

  installPhase = ''
    mkdir -p $out/share
    cp -r . $out/share/voctoweb

    ln -sf /run/voctoweb/database.yml $out/share/voctoweb/config/database.yml
    ln -sf /run/voctoweb/settings.yml $out/share/voctoweb/config/settings.yml
    rm -rf $out/share/voctoweb/tmp $out/share/voctoweb/public/system
    ln -sf /run/voctoweb/system $out/share/voctoweb/public/system
    ln -sf /tmp $out/share/voctoweb/tmp
  '';

  passthru = {
    inherit env ruby;
  };

  meta = with stdenv.lib; {
    description = "The frontend and backend software behind media.ccc.de";
    homepage = "https://github.com/voc/voctoweb";
    license = licenses.gpl3;
  };
}
