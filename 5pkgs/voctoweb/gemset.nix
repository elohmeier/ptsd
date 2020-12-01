{
  aasm = {
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1klsra30q7iz1icvycglzp677wsz48g71n52pkkmxfyxfwjr5jyf";
      type = "gem";
    };
    version = "5.0.1";
  };
  actioncable = {
    dependencies = [ "actionpack" "nio4r" "websocket-driver" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yvrnxvdzx3yvgkxwzffhkr8m4w19h97lyyj030g1q4xjii5a1kr";
      type = "gem";
    };
    version = "5.2.4.4";
  };
  actionmailer = {
    dependencies = [ "actionpack" "actionview" "activejob" "mail" "rails-dom-testing" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nhslq95il78h7qv7w7h7i9fx3znc5hxmqbnws0sl9w7am7zkl8x";
      type = "gem";
    };
    version = "5.2.4.4";
  };
  actionpack = {
    dependencies = [ "actionview" "activesupport" "rack" "rack-test" "rails-dom-testing" "rails-html-sanitizer" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d8gxymshjhva5fyv33iy2hzp4jm3i44asdbma9pv9wzpl5fwhn0";
      type = "gem";
    };
    version = "5.2.4.4";
  };
  actionview = {
    dependencies = [ "activesupport" "builder" "erubi" "rails-dom-testing" "rails-html-sanitizer" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k8dgkplqj76i3q1f8897m8svj2xggd1knhy3bcwfl4nh7998kw6";
      type = "gem";
    };
    version = "5.2.4.4";
  };
  activeadmin = {
    dependencies = [ "arbre" "formtastic" "formtastic_i18n" "inherited_resources" "jquery-rails" "kaminari" "railties" "ransack" "sassc-rails" "sprockets" "sprockets-es6" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1syyhh6nfqr6aa1fz1wcaqcsvmqym0xbpq6mh8fw70ds9w1ya2vq";
      type = "gem";
    };
    version = "2.4.0";
  };
  activejob = {
    dependencies = [ "activesupport" "globalid" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w32z0s111cr95mwpdb3fnlzaf1vdz0ag3l2gah9m95kfa2pb2kv";
      type = "gem";
    };
    version = "5.2.4.4";
  };
  activemodel = {
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g79l7v0ddpxcj5r2s9kii6h4r4nbpy5bksbqi5lxvivrb3pkz1m";
      type = "gem";
    };
    version = "5.2.4.4";
  };
  activerecord = {
    dependencies = [ "activemodel" "activesupport" "arel" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05b9l85a31cq6g7v4b4ifrj798q49rlidcvvfasmb3bk412wlp03";
      type = "gem";
    };
    version = "5.2.4.4";
  };
  activestorage = {
    dependencies = [ "actionpack" "activerecord" "marcel" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yzig9p9qb2wx91y0d0vs7bz23hli6djwwf4cawxh6b93bycbcci";
      type = "gem";
    };
    version = "5.2.4.4";
  };
  activesupport = {
    dependencies = [ "concurrent-ruby" "i18n" "minitest" "tzinfo" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dpnk20s754fz6jfz9sp3ri49hn46ksw4hf6ycnlw7s3hsdxqgcd";
      type = "gem";
    };
    version = "5.2.4.4";
  };
  airbrussh = {
    dependencies = [ "sshkit" ];
    groups = [ "capistrano" "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yp1sl5n94ksxpwmaajflbdls45s81hw4spgz01h19xs2zrvv8wl";
      type = "gem";
    };
    version = "1.3.0";
  };
  api-pagination = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d1l77563pz77cjvg74inxz9zdc1hlxa2rvhavdcv57msq5vnw6m";
      type = "gem";
    };
    version = "4.8.1";
  };
  apollo-federation = {
    dependencies = [ "google-protobuf" "graphql" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bxv5dbjd5ardvgz007dl31kdwbpkrkiy4bd48q42gbdyh4697dg";
      type = "gem";
    };
    version = "1.0.4";
  };
  arbre = {
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lr77dz1grdal9j43wlwskrvsdkyrnwb4npmldy3mjp0fim3id2q";
      type = "gem";
    };
    version = "1.2.1";
  };
  arel = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jk7wlmkr61f6g36w9s2sn46nmdg6wn2jfssrhbhirv5x9n95nk0";
      type = "gem";
    };
    version = "9.0.0";
  };
  autoprefixer-rails = {
    dependencies = [ "execjs" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0km15sbv173qck387yyl3zi8i4hp3i5adn9z2iiasa2xjf2lakb2";
      type = "gem";
    };
    version = "9.5.0";
  };
  babel-source = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ncq8h82k6hypzfb5dk7z95mmcdwnhsxmc53xz17m1nbklm25vvr";
      type = "gem";
    };
    version = "5.8.35";
  };
  babel-transpiler = {
    dependencies = [ "babel-source" "execjs" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w0minwxj56w96xps1msm6n75fs0y7r1vqcr9zlsn74fksnz81jc";
      type = "gem";
    };
    version = "0.7.0";
  };
  bcrypt = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02r1c3isfchs5fxivbq99gc3aq4vfyn8snhcy707dal1p8qz12qb";
      type = "gem";
    };
    version = "3.1.16";
  };
  bcrypt_pbkdf = {
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cj4k13c7qvvck7y25i3xarvyqq8d27vl61jddifkc7llnnap1hv";
      type = "gem";
    };
    version = "1.0.0";
  };
  bootstrap-sass = {
    dependencies = [ "autoprefixer-rails" "sassc" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1py78mv97c1m2w59s1h7fvs34j4hh66yln5275537a5hbr9p6ims";
      type = "gem";
    };
    version = "3.4.1";
  };
  builder = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "045wzckxpwcqzrjr353cxnyaxgf0qg22jh00dcx7z38cys5g1jlr";
      type = "gem";
    };
    version = "3.2.4";
  };
  bullet = {
    dependencies = [ "activesupport" "uniform_notifier" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g4qjqagqvcdn77fk0smmf5bfm5473ajr7965hw66cl70v155pgv";
      type = "gem";
    };
    version = "5.8.1";
  };
  byebug = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10znc1hjv8n686hhpl08f3m2g6h08a4b83nxblqwy2kqamkxcqf8";
      type = "gem";
    };
    version = "10.0.2";
  };
  capistrano = {
    dependencies = [ "airbrussh" "capistrano-harrow" "i18n" "rake" "sshkit" ];
    groups = [ "capistrano" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0c60n6bwzrc708j6l7a9fhjywkyh9zf6s7klw4cwgp477lmdngik";
      type = "gem";
    };
    version = "3.5.0";
  };
  capistrano-bundler = {
    dependencies = [ "capistrano" "sshkit" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18vm7ssjcayb73yin5p5wa3cxdib5dp526wfjrc1zsvsicna5h42";
      type = "gem";
    };
    version = "1.4.0";
  };
  capistrano-harrow = {
    groups = [ "capistrano" "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02i24xg2g0ypvawr87izsxdajp308gwlffjamnmx5fb6kxs6vmvl";
      type = "gem";
    };
    version = "0.5.3";
  };
  capistrano-rails = {
    dependencies = [ "capistrano" "capistrano-bundler" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19j82kiarrph1ilw2xfhfj62z0b53w0gph7613b21iccb2gn3dqy";
      type = "gem";
    };
    version = "1.4.0";
  };
  capistrano-rvm = {
    dependencies = [ "capistrano" "sshkit" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15sy8zcal041yy5kb7fcdqnxvndgdhg3w1kvb5dk7hfjk3ypznsa";
      type = "gem";
    };
    version = "0.1.2";
  };
  capistrano-sidekiq = {
    dependencies = [ "capistrano" "sidekiq" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "084r14zxx3ma6ykv6lnhhij4ni7yv6hkvpqr706smlmvkyyznpvl";
      type = "gem";
    };
    version = "0.10.0";
  };
  coderay = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15vav4bhcc2x3jmi3izb11l4d9f3xv8hp2fszb7iqmpsccv1pz4y";
      type = "gem";
    };
    version = "1.1.2";
  };
  coffee-rails = {
    dependencies = [ "coffee-script" "railties" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jp81gjcid66ialk5n242y27p3payy0cz6c6i80ik02nx54mq2h8";
      type = "gem";
    };
    version = "4.2.2";
  };
  coffee-script = {
    dependencies = [ "coffee-script-source" "execjs" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rc7scyk7mnpfxqv5yy4y5q1hx3i7q3ahplcp4bq2g5r24g2izl2";
      type = "gem";
    };
    version = "2.4.1";
  };
  coffee-script-source = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1907v9q1zcqmmyqzhzych5l7qifgls2rlbnbhy5vzyr7i7yicaz1";
      type = "gem";
    };
    version = "1.12.2";
  };
  concurrent-ruby = {
    groups = [ "capistrano" "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vnxrbhi7cq3p4y2v9iwd10v1c7l15is4var14hwnb2jip4fyjzz";
      type = "gem";
    };
    version = "1.1.7";
  };
  connection_pool = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lflx29mlznf1hn0nihkgllzbj8xp5qasn8j7h838465pi399k68";
      type = "gem";
    };
    version = "2.2.2";
  };
  crass = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      type = "gem";
    };
    version = "1.0.6";
  };
  devise = {
    dependencies = [ "bcrypt" "orm_adapter" "railties" "responders" "warden" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0syqkh0q9mcdgj68m2cf1innpxb8fv6xsayk1kgsdmq539rkv3ic";
      type = "gem";
    };
    version = "4.7.3";
  };
  dotenv = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1va5y19f7l5jh53vz5vibz618lg8z93k5m2k70l25s9k46v2gfm3";
      type = "gem";
    };
    version = "2.5.0";
  };
  dotenv-rails = {
    dependencies = [ "dotenv" "railties" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vmk541bhb2mw0gfc1bg43jdilqspiggxzglnlr26rzsmvy2cgd2";
      type = "gem";
    };
    version = "2.5.0";
  };
  ed25519 = {
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1f5kr8za7hvla38fc0n9jiv55iq62k5bzclsa5kdb14l3r4w6qnw";
      type = "gem";
    };
    version = "1.2.4";
  };
  elasticsearch = {
    dependencies = [ "elasticsearch-api" "elasticsearch-transport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "162a7aiajs7w3rak21y6jidik7zhkm104wcx25190llyqbqkvlp9";
      type = "gem";
    };
    version = "6.1.0";
  };
  elasticsearch-api = {
    dependencies = [ "multi_json" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0q9shhpifl6cir68zxv30mjjybxsx39asqnircrgs4lqsb20j1n7";
      type = "gem";
    };
    version = "6.1.0";
  };
  elasticsearch-model = {
    dependencies = [ "activesupport" "elasticsearch" "hashie" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09w8lja4nnx7radw4skb6wipa01bwmxayw4dgbk9yvh8fj6gi21y";
      type = "gem";
    };
    version = "6.0.0";
  };
  elasticsearch-rails = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06k97w4xdkdj982b2mgz4bv0gvkpbscn4wxsrqj6kr1x7dxia394";
      type = "gem";
    };
    version = "6.1.1";
  };
  elasticsearch-transport = {
    dependencies = [ "faraday" "multi_json" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dmb587mp526q1wvb1j13rjj13vxl4fcpmm899ipyr88spld5vc7";
      type = "gem";
    };
    version = "6.1.0";
  };
  erubi = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nwzxnqhr31fn7nbqmffcysvxjdfl3bhxi0bld5qqhcnfc1xd13x";
      type = "gem";
    };
    version = "1.9.0";
  };
  exception_notification = {
    dependencies = [ "actionmailer" "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1i1f5qr1ns0caf96zglhmzcwkfl4fqg0yyygbq1qvw8jpfqw35cq";
      type = "gem";
    };
    version = "4.2.2";
  };
  execjs = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yz55sf2nd3l666ms6xr18sm2aggcvmb8qr3v53lr4rir32y1yp1";
      type = "gem";
    };
    version = "2.7.0";
  };
  factory_bot = {
    dependencies = [ "activesupport" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13q1b7imb591068plg4ashgsqgzarvfjz6xxn3jk6klzikz5zhg1";
      type = "gem";
    };
    version = "4.11.1";
  };
  factory_bot_rails = {
    dependencies = [ "factory_bot" "railties" ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pkmsmb8f313003ss9x93s90lf5pj1wazwfhhqgcxw4r2m5dam2z";
      type = "gem";
    };
    version = "4.11.1";
  };
  faraday = {
    dependencies = [ "multipart-post" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16hwxc8v0z6gkanckjhx0ffgqmzpc4ywz4dfhxpjlz2mbz8d5m52";
      type = "gem";
    };
    version = "0.15.3";
  };
  ffi = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10lfhahnnc91v63xpvk65apn61pib086zha3z5sp1xk9acfx12h4";
      type = "gem";
    };
    version = "1.12.2";
  };
  foreman = {
    dependencies = [ "thor" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wd0zv956ha2pvf1j0191sd8nivyp1py0qnqaz57mbw43hs4qx41";
      type = "gem";
    };
    version = "0.85.0";
  };
  formtastic = {
    dependencies = [ "actionpack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1grh06zzrxq3zr8fvg02ipallrjx849h59ck16rbpgn0n31i248a";
      type = "gem";
    };
    version = "3.1.5";
  };
  formtastic_i18n = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l7z15jv7gfd75s89wbiz3i96cqkg0lgxvbij1j1dffk6qiyllvs";
      type = "gem";
    };
    version = "0.6.0";
  };
  get_process_mem = {
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q7pivp9z9pdxc2ha32q7x9zgqy8m9jf87g6n5mvi5l6knxya8sh";
      type = "gem";
    };
    version = "0.2.5";
  };
  globalid = {
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zkxndvck72bfw235bd9nl2ii0lvs5z88q14706cmn702ww2mxv1";
      type = "gem";
    };
    version = "0.4.2";
  };
  goldiloader = {
    dependencies = [ "activerecord" "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05xqbn36m7g4868k44bdn8kfgp9gbbf4nc73ayr7rh1k5xk29hvy";
      type = "gem";
    };
    version = "3.1.1";
  };
  google-protobuf = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1swxvka4qcfa986qr5d3hxqlcsraxfb6fsc0mf2ngxmq15wad8br";
      type = "gem";
    };
    version = "3.11.4";
  };
  graphiql-rails = {
    dependencies = [ "railties" "sprockets-rails" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "103ksbzh33jikxkz52gggiwwrrj4yfv96f70v2g3vyj5c0yzyjiq";
      type = "gem";
    };
    version = "1.7.0";
  };
  graphql = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1y36bq970ij5n12cjs6bwzc0byyc3pxx8xl9wg1cspk6xiqixr4j";
      type = "gem";
    };
    version = "1.10.8";
  };
  graphql-query-resolver = {
    dependencies = [ "graphql" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lww532vrp231lmwvvg1qk5cpqkl7vzm5k1k0p7z6r7nphrrq0zn";
      type = "gem";
    };
    version = "0.2.0";
  };
  haml = {
    dependencies = [ "temple" "tilt" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q0a9fvqh8kn6wm97fcks6qzbjd400bv8bx748w8v87m7p4klhac";
      type = "gem";
    };
    version = "5.0.4";
  };
  has_scope = {
    dependencies = [ "actionpack" "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14df3am60hmyadjz2wah1qny2l5as51gvlxd0nycygmiqbfa0kyg";
      type = "gem";
    };
    version = "0.7.2";
  };
  hashie = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13bdzfp25c8k51ayzxqkbzag3wj5gc1jd8h7d985nsq6pn57g5xh";
      type = "gem";
    };
    version = "3.6.0";
  };
  i18n = {
    dependencies = [ "concurrent-ruby" ];
    groups = [ "capistrano" "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "153sx77p16vawrs4qpkv7qlzf9v5fks4g7xqcj1dwk40i6g7rfzk";
      type = "gem";
    };
    version = "1.8.5";
  };
  inherited_resources = {
    dependencies = [ "actionpack" "has_scope" "railties" "responders" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04gy7yc6q56gs1c290xmycsp7256lnkqk3cdx7m2k5q99rkvmibj";
      type = "gem";
    };
    version = "1.11.0";
  };
  jbuilder = {
    dependencies = [ "activesupport" "multi_json" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n3myqk2hdnidzzbgcdz2r1y4cr5vpz5nkfzs0lz4y9gkjbjyh2j";
      type = "gem";
    };
    version = "2.7.0";
  };
  jquery-rails = {
    dependencies = [ "rails-dom-testing" "railties" "thor" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wr6302mvj701skpy5iap4zdnjk6k77cvdjr6xw8bil2lsv5zvqq";
      type = "gem";
    };
    version = "4.3.5";
  };
  kaminari = {
    dependencies = [ "activesupport" "kaminari-actionview" "kaminari-activerecord" "kaminari-core" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vxkqciny5v4jgmjxl8qrgbmig2cij2iskqbwh4bfcmpxf467ch3";
      type = "gem";
    };
    version = "1.2.1";
  };
  kaminari-actionview = {
    dependencies = [ "actionview" "kaminari-core" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w0p1hyv6lgf6h036cmn2kbkdv4x7g0g9q9kc5gzkpz7amlxr8ri";
      type = "gem";
    };
    version = "1.2.1";
  };
  kaminari-activerecord = {
    dependencies = [ "activerecord" "kaminari-core" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02n5xxv6ilh39q2m6vcz7qrdai7ghk3s178dw6f0b3lavwyq49w3";
      type = "gem";
    };
    version = "1.2.1";
  };
  kaminari-core = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h04cr4y1jfn81gxy439vmczifghc2cvsyw47aa32is5bbxg1wlz";
      type = "gem";
    };
    version = "1.2.1";
  };
  listen = {
    dependencies = [ "rb-fsevent" "rb-inotify" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w923wmdi3gyiky0asqdw5dnh3gcjs2xyn82ajvjfjwh6sn0clgi";
      type = "gem";
    };
    version = "3.2.1";
  };
  lograge = {
    dependencies = [ "actionpack" "activesupport" "railties" "request_store" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vrjm4yqn5l6q5gsl72fmk95fl6j9z1a05gzbrwmsm3gp1a1bgac";
      type = "gem";
    };
    version = "0.11.2";
  };
  loofah = {
    dependencies = [ "crass" "nokogiri" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1alz1x6rkhbw10qpszr384299rf52rcyasn0619a9p50vzs8vczq";
      type = "gem";
    };
    version = "2.7.0";
  };
  mail = {
    dependencies = [ "mini_mime" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00wwz6ys0502dpk8xprwcqfwyf3hmnx6lgxaiq6vj43mkx43sapc";
      type = "gem";
    };
    version = "2.7.1";
  };
  marcel = {
    dependencies = [ "mimemagic" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nxbjmcyg8vlw6zwagf17l9y2mwkagmmkg95xybpn4bmf3rfnksx";
      type = "gem";
    };
    version = "0.3.3";
  };
  method_source = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pviwzvdqd90gn6y7illcdd9adapw8fczml933p5vl739dkvl3lq";
      type = "gem";
    };
    version = "0.9.2";
  };
  mimemagic = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qfqb9w76kmpb48frbzbyvjc0dfxh5qiw1kxdbv2y2kp6fxpa1kf";
      type = "gem";
    };
    version = "0.3.5";
  };
  mini_mime = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1axm0rxyx3ss93wbmfkm78a6x03l8y4qy60rhkkiq0aza0vwq3ha";
      type = "gem";
    };
    version = "1.0.2";
  };
  mini_portile2 = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15zplpfw3knqifj9bpf604rb3wc1vhq6363pd6lvhayng8wql5vy";
      type = "gem";
    };
    version = "2.4.0";
  };
  minitest = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "170y2cvx51gm3cm3nhdf7j36sxnkh6vv8ls36p90ric7w8w16h4v";
      type = "gem";
    };
    version = "5.14.2";
  };
  mqtt = {
    groups = [ "development" ];
    platforms = [ ];
    source = {
      fetchSubmodules = false;
      rev = "bee5d3fa93103995ee5b3992eceb16246ef8dfb1";
      sha256 = "0ixh2cmqjqm0ykh7wm39ddqnr5n2d204cjbwg9qqcw0jl4bl6ahs";
      type = "git";
      url = "https://github.com/njh/ruby-mqtt.git";
    };
    version = "0.5.0";
  };
  multi_json = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rl0qy4inf1mp8mybfk56dfga0mvx97zwpmq5xmiwl5r770171nv";
      type = "gem";
    };
    version = "1.13.1";
  };
  multipart-post = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09k0b3cybqilk1gwrwwain95rdypixb2q9w65gd44gfzsd84xi1x";
      type = "gem";
    };
    version = "2.0.0";
  };
  net-scp = {
    dependencies = [ "net-ssh" ];
    groups = [ "capistrano" "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b0jqrcsp4bbi4n4mzyf70cp2ysyp6x07j8k8cqgxnvb4i3a134j";
      type = "gem";
    };
    version = "1.2.1";
  };
  net-ssh = {
    groups = [ "capistrano" "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qfanf71yv8w7yl9l9wqcy68i2x1ghvnf8m581yy4pl0anfdhqw8";
      type = "gem";
    };
    version = "5.0.2";
  };
  nio4r = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cbwp1kbv6b2qfxv8sarv0d0ilb257jihlvdqj8f5pdm0ksq1sgk";
      type = "gem";
    };
    version = "2.5.4";
  };
  nokogiri = {
    dependencies = [ "mini_portile2" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xmf60nj5kg9vaj5bysy308687sgmkasgx06vbbnf94p52ih7si2";
      type = "gem";
    };
    version = "1.10.10";
  };
  orm_adapter = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fg9jpjlzf5y49qs9mlpdrgs5rpcyihq1s4k79nv9js0spjhnpda";
      type = "gem";
    };
    version = "0.5.0";
  };
  pg = {
    groups = [ "postgresql" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pnjw3rspdfjssxyf42jnbsdlgri8ylysimp0s28wxb93k6ff2qb";
      type = "gem";
    };
    version = "1.1.3";
  };
  polyamorous = {
    dependencies = [ "activerecord" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k8j8rxllk3zibhlixsd4qqrxpmqp3nbq3nbkczrc6mvz1bj7nfc";
      type = "gem";
    };
    version = "2.3.0";
  };
  pry = {
    dependencies = [ "coderay" "method_source" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mh312k3y94sj0pi160wpia0ps8f4kmzvm505i6bvwynfdh7v30g";
      type = "gem";
    };
    version = "0.11.3";
  };
  pry-byebug = {
    dependencies = [ "byebug" "pry" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y2758593i2ij0nhmv0j1pbdfx2cgi52ns6wkij0frgnk2lf650g";
      type = "gem";
    };
    version = "3.6.0";
  };
  pry-rails = {
    dependencies = [ "pry" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k2d43bwmqbswfra4fkadjjbszwb11pr7qdkma91qrcrk62wqxvy";
      type = "gem";
    };
    version = "0.3.6";
  };
  puma = {
    dependencies = [ "nio4r" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cly51sqlz4ydpi5cshbrgjqgmysy26yca01lpnvhqvfvb4y9gl8";
      type = "gem";
    };
    version = "4.3.5";
  };
  puma_worker_killer = {
    dependencies = [ "get_process_mem" "puma" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jwdmsj7bcmlzr504kwi3qhrjfd6b667paksv9mrv0vdip3if3jn";
      type = "gem";
    };
    version = "0.1.1";
  };
  rack = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0i5vs0dph9i5jn8dfc6aqd6njcafmb20rwqngrf759c9cvmyff16";
      type = "gem";
    };
    version = "2.2.3";
  };
  rack-cors = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jvs0mq8jrsz86jva91mgql16daprpa3qaipzzfvngnnqr5680j7";
      type = "gem";
    };
    version = "1.1.1";
  };
  rack-protection = {
    dependencies = [ "rack" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ylx74ravz7nvnyygq0nk3v86qdzrmqxpwpayhppyy50l72rcajq";
      type = "gem";
    };
    version = "2.0.4";
  };
  rack-test = {
    dependencies = [ "rack" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rh8h376mx71ci5yklnpqqn118z3bl67nnv5k801qaqn1zs62h8m";
      type = "gem";
    };
    version = "1.1.0";
  };
  rails = {
    dependencies = [ "actioncable" "actionmailer" "actionpack" "actionview" "activejob" "activemodel" "activerecord" "activestorage" "activesupport" "railties" "sprockets-rails" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b5g3h5sbbncks44w8vjnx0zp145ygphrsspy4ay7xsls92xynq0";
      type = "gem";
    };
    version = "5.2.4.4";
  };
  rails-controller-testing = {
    dependencies = [ "actionpack" "actionview" "activesupport" ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16kdkk73mhhs73iz3i1i0ryjm84dadiyh817b3nh8acdi490jyhy";
      type = "gem";
    };
    version = "1.0.2";
  };
  rails-dom-testing = {
    dependencies = [ "activesupport" "nokogiri" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lfq2a7kp2x64dzzi5p4cjcbiv62vxh9lyqk2f0rqq3fkzrw8h5i";
      type = "gem";
    };
    version = "2.0.3";
  };
  rails-html-sanitizer = {
    dependencies = [ "loofah" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1icpqmxbppl4ynzmn6dx7wdil5hhq6fz707m9ya6d86c7ys8sd4f";
      type = "gem";
    };
    version = "1.3.0";
  };
  railties = {
    dependencies = [ "actionpack" "activesupport" "method_source" "rake" "thor" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "089kiwmv8fxyfk0zp57q74nyd5i6d5x5ihlrzbzwl041v94s2zx9";
      type = "gem";
    };
    version = "5.2.4.4";
  };
  rake = {
    groups = [ "capistrano" "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w6qza25bq1s825faaglkx1k6d59aiyjjk3yw3ip5sb463mhhai9";
      type = "gem";
    };
    version = "13.0.1";
  };
  ransack = {
    dependencies = [ "actionpack" "activerecord" "activesupport" "i18n" "polyamorous" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sx8n2w1hxm5la087navlpjgh4fzdq2jhw3xwldgxz0iqn83kag6";
      type = "gem";
    };
    version = "2.3.0";
  };
  rb-fsevent = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k9bsj7ni0g2fd7scyyy1sk9dy2pg9akniahab0iznvjmhn54h87";
      type = "gem";
    };
    version = "0.10.4";
  };
  rb-inotify = {
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jm76h8f8hji38z3ggf4bzi8vps6p7sagxn3ab57qc0xyga64005";
      type = "gem";
    };
    version = "0.10.1";
  };
  rdoc = {
    groups = [ "default" "doc" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0anv42cqcdc6g4n386mrva7mgav5i0c2ry3yzvzzc6z6hymkmcr7";
      type = "gem";
    };
    version = "6.0.4";
  };
  redcarpet = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0skcyx1h8b5ms0rp2zm3ql6g322b8c1adnkwkqyv7z3kypb4bm7k";
      type = "gem";
    };
    version = "3.5.0";
  };
  redis = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m0z8kfqfbd1ln12zl1pzvplb978xnr78p4wwq8w8nk57gzsy08c";
      type = "gem";
    };
    version = "4.0.3";
  };
  redis-actionpack = {
    dependencies = [ "actionpack" "redis-rack" "redis-store" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15k41gz7nygd4yydk2yd25gghya1j7q6zifk4mdrra6bwnwjbm63";
      type = "gem";
    };
    version = "5.0.2";
  };
  redis-activesupport = {
    dependencies = [ "activesupport" "redis-store" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y1df62gpqgy0yrlmgl05rp4kb0xvn0kylprhv1k32bs33dgpv62";
      type = "gem";
    };
    version = "5.0.7";
  };
  redis-rack = {
    dependencies = [ "rack" "redis-store" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0px0wv8zripc6lrn3k0k61j6nlxda145q8sz50yvnig17wlk36gb";
      type = "gem";
    };
    version = "2.0.4";
  };
  redis-rails = {
    dependencies = [ "redis-actionpack" "redis-activesupport" "redis-store" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hjvkyaw5hgz7v6fgwdk8pb966z44h1gv8jarmb0gwhkqmjnsh40";
      type = "gem";
    };
    version = "5.0.2";
  };
  redis-store = {
    dependencies = [ "redis" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mrcnjgkbmx1zf569mly82agdizqayjvnp2k6055k1iy07in3j8b";
      type = "gem";
    };
    version = "1.6.0";
  };
  request_store = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cx74kispmnw3ljwb239j65a2j14n8jlsygy372hrsa8mxc71hxi";
      type = "gem";
    };
    version = "1.5.0";
  };
  responders = {
    dependencies = [ "actionpack" "railties" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14kjykc6rpdh24sshg9savqdajya2dislc1jmbzg91w9967f4gv1";
      type = "gem";
    };
    version = "3.0.1";
  };
  rexml = {
    groups = [ "default" "doc" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mkvkcw9fhpaizrhca0pdgjcrbns48rlz4g6lavl5gjjq3rk2sq3";
      type = "gem";
    };
    version = "3.2.4";
  };
  ruby-graphviz = {
    dependencies = [ "rexml" ];
    groups = [ "doc" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "010m283gk4qgzxkgrldlnrglh8d5fn6zvrzm56wf5abd7x7b8aqw";
      type = "gem";
    };
    version = "1.2.5";
  };
  sass = {
    dependencies = [ "sass-listen" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0p95lhs0jza5l7hqci1isflxakz83xkj97lkvxl919is0lwhv2w0";
      type = "gem";
    };
    version = "3.7.4";
  };
  sass-listen = {
    dependencies = [ "rb-fsevent" "rb-inotify" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xw3q46cmahkgyldid5hwyiwacp590zj2vmswlll68ryvmvcp7df";
      type = "gem";
    };
    version = "4.0.0";
  };
  sass-rails = {
    dependencies = [ "railties" "sass" "sprockets" "sprockets-rails" "tilt" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wa63sbsimrsf7nfm8h0m1wbsllkfxvd7naph5d1j6pbc555ma7s";
      type = "gem";
    };
    version = "5.0.7";
  };
  sassc = {
    dependencies = [ "ffi" "rake" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sr4825rlwsrl7xrsm0sgalcpf5zgp4i56dbi3qxfa9lhs8r6zh4";
      type = "gem";
    };
    version = "2.0.1";
  };
  sassc-rails = {
    dependencies = [ "railties" "sassc" "sprockets" "sprockets-rails" "tilt" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1d9djmwn36a5m8a83bpycs48g8kh1n2xkyvghn7dr6zwh4wdyksz";
      type = "gem";
    };
    version = "2.1.2";
  };
  sdoc = {
    dependencies = [ "rdoc" ];
    groups = [ "doc" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sw4ai8wk7q1kx8m3wc2bskky3pchf8lw045gymlb53v27fm0sbh";
      type = "gem";
    };
    version = "1.0.0";
  };
  search_object = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pzmarli5a9lbg7jka46njm32kk5zjhr3bcpvfn6i2l8q817ikdq";
      type = "gem";
    };
    version = "1.2.3";
  };
  search_object_graphql = {
    dependencies = [ "graphql" "search_object" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s3ffd0xsmz6jywq6dsrm9lpxnkhln459m0hzvw7l5215mzsxmj8";
      type = "gem";
    };
    version = "0.3.1";
  };
  sidekiq = {
    dependencies = [ "connection_pool" "rack-protection" "redis" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06jws6zlyxqdbpcyvdd61ylp9cxsg2h4bs2mmz3k2ah42p5xxkjp";
      type = "gem";
    };
    version = "5.2.2";
  };
  sprockets = {
    dependencies = [ "concurrent-ruby" "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "182jw5a0fbqah5w9jancvfmjbk88h8bxdbwnl4d3q809rpxdg8ay";
      type = "gem";
    };
    version = "3.7.2";
  };
  sprockets-es6 = {
    dependencies = [ "babel-source" "babel-transpiler" "sprockets" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0508h3vnjz08c64k11za6cqnbvvifka9pmdrycamzzjd4dmf10y3";
      type = "gem";
    };
    version = "0.9.2";
  };
  sprockets-rails = {
    dependencies = [ "actionpack" "activesupport" "sprockets" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mwmz36265646xqfyczgr1mhkm1hfxgxxvgdgr4xfcbf2g72p1k2";
      type = "gem";
    };
    version = "3.2.2";
  };
  sshkit = {
    dependencies = [ "net-scp" "net-ssh" ];
    groups = [ "capistrano" "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w8wmi225clqjsii97820r582swlj86dp4pcl7asih0f5s561csm";
      type = "gem";
    };
    version = "1.18.0";
  };
  temple = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00nxf610nzi4n1i2lkby43nrnarvl89fcl6lg19406msr0k3ycmq";
      type = "gem";
    };
    version = "0.8.0";
  };
  thor = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01n5dv9kql60m6a00zc0r66jvaxx98qhdny3klyj0p3w34pad2ns";
      type = "gem";
    };
    version = "0.19.4";
  };
  thread_safe = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nmhcgq6cgz44srylra07bmaw99f5271l0dpsvl5f75m44l0gmwy";
      type = "gem";
    };
    version = "0.3.6";
  };
  tilt = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0020mrgdf11q23hm1ddd6fv691l51vi10af00f137ilcdb2ycfra";
      type = "gem";
    };
    version = "2.0.8";
  };
  tinymce-rails = {
    dependencies = [ "railties" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pmbdc7wyj7fvf0p9my6xa1d7ky20r5si4km4gidjs4salcwvjyf";
      type = "gem";
    };
    version = "5.1.4.1";
  };
  turbolinks = {
    dependencies = [ "turbolinks-source" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jd1bnbzac6dkpw8i10fsz38nfnfak82s6yqpxrpnn1zsaw02ipr";
      type = "gem";
    };
    version = "5.2.0";
  };
  turbolinks-source = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1m45pk1jbfvqaki1mxn1bmj8yy65qyv49ygqbkqv08hshpx42ain";
      type = "gem";
    };
    version = "5.2.0";
  };
  tzinfo = {
    dependencies = [ "thread_safe" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1i3jh086w1kbdj3k5l60lc3nwbanmzdf8yjj3mlrx9b2gjjxhi9r";
      type = "gem";
    };
    version = "1.2.7";
  };
  uglifier = {
    dependencies = [ "execjs" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g203kly5wp4qlkc7371skyvyin6iinc8i0p5wrpiqgblqxxgcf1";
      type = "gem";
    };
    version = "4.1.19";
  };
  uniform_notifier = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mb0pq99zm17qnz2czmad5b3z0ivzkf6493afj3n550kd56z18s3";
      type = "gem";
    };
    version = "1.12.1";
  };
  utf8-cleaner = {
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01r4vr33w602p3xz0fjdy6ghd0xm7hk356v3v59j7yqhpy4c66vf";
      type = "gem";
    };
    version = "0.2.5";
  };
  warden = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1l7gl7vms023w4clg02pm4ky9j12la2vzsixi2xrv9imbn44ys26";
      type = "gem";
    };
    version = "1.2.9";
  };
  websocket-driver = {
    dependencies = [ "websocket-extensions" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1i3rs4kcj0jba8idxla3s6xd1xfln3k8b4cb1dik2lda3ifnp3dh";
      type = "gem";
    };
    version = "0.7.3";
  };
  websocket-extensions = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hc2g9qps8lmhibl5baa91b4qx8wqw872rgwagml78ydj8qacsqw";
      type = "gem";
    };
    version = "0.1.5";
  };
  yajl-ruby = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16v0w5749qjp13xhjgr2gcsvjv6mf35br7iqwycix1n2h7kfcckf";
      type = "gem";
    };
    version = "1.4.1";
  };
}
