{
  actioncable = {
    dependencies = [ "actionpack" "activesupport" "nio4r" "websocket-driver" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fdbks9byqqlkd6glj6lkz5f1z6948hh8fhv9x5pzqciralmz142";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  actionmailbox = {
    dependencies = [ "actionpack" "activejob" "activerecord" "activestorage" "activesupport" "mail" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rfya6qgsl14cm9l2w7h7lg4znsyg3gqiskhqr8wn76sh0x2hln0";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  actionmailer = {
    dependencies = [ "actionpack" "actionview" "activejob" "activesupport" "mail" "rails-dom-testing" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jr9jpf542svzqz8x68s08jnf30shxrrh7rq1a0s7jia5a5zx3qd";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  actionpack = {
    dependencies = [ "actionview" "activesupport" "rack" "rack-test" "rails-dom-testing" "rails-html-sanitizer" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vf6ncs647psa9p23d2108zgmlf0pr7gcjr080yg5yf68gyhs53k";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  actiontext = {
    dependencies = [ "actionpack" "activerecord" "activestorage" "activesupport" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1i8s3v6m8q3y17c40l6d3k2vs1mdqr0y1lfm7i6dfbj2y673lk9r";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  actionview = {
    dependencies = [ "activesupport" "builder" "erubi" "rails-dom-testing" "rails-html-sanitizer" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s4c1n5lv31sc7w4w74xz8gzyq3sann00bm4l7lxgy3vgi2wqkid";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  activejob = {
    dependencies = [ "activesupport" "globalid" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1641003plszig5ybhrqy90fv43l1vcai5h35qmhh9j12byk5hp26";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  activemodel = {
    dependencies = [ "activesupport" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "148szdj5jlnfpv3nmy8cby8rxgpdvs43f3rzqby1f7a0l2knd3va";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  activerecord = {
    dependencies = [ "activemodel" "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n7hg582ajdncilfk1kkw8qfdchymp2gqgkad1znlhlmclihsafr";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  activestorage = {
    dependencies = [ "actionpack" "activejob" "activerecord" "activesupport" "marcel" "mini_mime" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16pylwnqsbvq2wxhl7k1rnravbr3dgpjmnj0psz5gijgkydd52yc";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  activesupport = {
    dependencies = [ "concurrent-ruby" "i18n" "minitest" "tzinfo" "zeitwerk" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nhrdih0rk46i0s6x7nqhbypmj1hf23zl5gfl9xasb6k4r2a1dxk";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  acts_as_tree = {
    dependencies = [ "activerecord" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wx2m64knv57g1q0bi09d7hci69x5n49xkzzcimn2f6ym08fnsdq";
      type = "gem";
    };
    version = "2.9.1";
  };
  addressable = {
    dependencies = [ "public_suffix" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "022r3m9wdxljpbya69y2i3h9g3dhhfaqzidf95m6qjzms792jvgp";
      type = "gem";
    };
    version = "2.8.0";
  };
  ast = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04nc8x27hlzlrr5c2gn7mar4vdr0apw5xg22wp6m8dx3wqr04a0y";
      type = "gem";
    };
    version = "2.4.2";
  };
  autoprefixer-rails = {
    dependencies = [ "execjs" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hax4yd41f61ypfs7f0snjzbcgpp19s9d2i0bv4hyjv21kkdz736";
      type = "gem";
    };
    version = "10.4.13.0";
  };
  bcrypt = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ysblqxkclmnhrd0kmb5mr8p38mbar633gdsb14b7dhkhgawgzfy";
      type = "gem";
    };
    version = "3.1.12";
  };
  bindex = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zmirr3m02p52bzq4xgksq4pn8j641rx5d4czk68pv9rqnfwq7kv";
      type = "gem";
    };
    version = "0.8.1";
  };
  blankslate = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fwkb4d1j9gc7vdwn2nxvwgy2g5wlag4c4bp7bl85jvq0kgp6cyx";
      type = "gem";
    };
    version = "3.1.3";
  };
  bootsnap = {
    dependencies = [ "msgpack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yza43f42v0ys81y6jzbqfkdykf40h6l3yyvadwq32fswrbpwvbc";
      type = "gem";
    };
    version = "1.12.0";
  };
  bootstrap = {
    dependencies = [ "autoprefixer-rails" "popper_js" "sassc-rails" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w0p1yisksl1nfzhw964scsx1wvb0pr5r82h8qd1h8v16m6pfdr0";
      type = "gem";
    };
    version = "5.2.3";
  };
  brakeman = {
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lcxxlrzgpi9z2mr2v19xda6fdysmn5psa9bsp2rksa915v91fds";
      type = "gem";
    };
    version = "5.4.0";
  };
  builder = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "045wzckxpwcqzrjr353cxnyaxgf0qg22jh00dcx7z38cys5g1jlr";
      type = "gem";
    };
    version = "3.2.4";
  };
  bundler-audit = {
    dependencies = [ "thor" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gdx0019vj04n1512shhdx7hwphzqmdpw4vva2k551nd47y1dixx";
      type = "gem";
    };
    version = "0.9.1";
  };
  byebug = {
    groups = [ "development" "test" ];
    platforms = [{
      engine = "maglev";
    }
      {
        engine = "ruby";
      }];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18a9wlwvwxi86nldj56jbk6pwx3rd8l5xi6p8ap24p169h9m8wc4";
      type = "gem";
    };
    version = "11.1.1";
  };
  cancancan = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gmvkqmnllja52573gjdskadcxds2ry04z00gwqvh1lc6jb6m97r";
      type = "gem";
    };
    version = "1.17.0";
  };
  capybara = {
    dependencies = [ "addressable" "mini_mime" "nokogiri" "rack" "rack-test" "regexp_parser" "xpath" ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1viqcpsngy9fqjd68932m43ad6xj656d1x33nx9565q57chgi29k";
      type = "gem";
    };
    version = "3.35.3";
  };
  chronic = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hrdkn4g8x7dlzxwb1rfgr8kw3bp4ywg5l4y4i9c2g5cwv62yvvn";
      type = "gem";
    };
    version = "0.10.2";
  };
  coderay = {
    groups = [ "default" "test" ];
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
      sha256 = "170sp4y82bf6nsczkkkzypzv368sgjg6lfrkib4hfjgxa6xa3ajx";
      type = "gem";
    };
    version = "5.0.0";
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
  combustion = {
    dependencies = [ "activesupport" "railties" "thor" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1m0q1a0smgf8ixfkj4rbwdv4n5alzqpny10gyvcb4xgmci0xyywx";
      type = "gem";
    };
    version = "0.6.0";
  };
  concurrent-ruby = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0krcwb6mn0iklajwngwsg850nk8k9b35dhmc2qkbdqvmifdi2y9q";
      type = "gem";
    };
    version = "1.2.2";
  };
  crass = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      type = "gem";
    };
    version = "1.0.6";
  };
  database_cleaner = {
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q5g322rzp05z4vh2y0qdabj2wp0a8hwn391y47f2gv6ahi9z3pk";
      type = "gem";
    };
    version = "1.8.2";
  };
  date = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03skfikihpx37rc27vr3hwrb057gxnmdzxhmzd4bf4jpkl0r55w1";
      type = "gem";
    };
    version = "3.3.3";
  };
  diff-lcs = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rwvjahnp7cpmracd8x732rjgnilqv2sx7d1gfrysslc3h039fa9";
      type = "gem";
    };
    version = "1.5.0";
  };
  differ = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0iayb71yqw5bgarq829fwchykw8lsqm8alnjc6c2m6k74fvnvkjy";
      type = "gem";
    };
    version = "0.1.2";
  };
  dradis-acunetix = {
    dependencies = [ "dradis-plugins" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k5gn9zrzqgd2dn51n590rqaa73wkqx4ys8kibmdf9i87zd7nxq7";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-api = {
    dependencies = [ "jbuilder" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      path = engines/dradis-api;
      type = "path";
    };
    version = "4.10.0";
  };
  dradis-brakeman = {
    dependencies = [ "dradis-plugins" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zn09r24z84vfldymcc8k7fy157na4dzkxqbjn7r96jsmvilq0sq";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-burp = {
    dependencies = [ "dradis-plugins" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ff2xfwyyxmlkbkaka9wbz7fm8qhcxh45ccg082gsrjk0rcq6sdn";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-calculator_cvss = {
    dependencies = [ "dradis-plugins" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xfl7irsqja9cwanivhxddf82adwlkqi77f0xrisn6yr8dmax8m0";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-calculator_dread = {
    dependencies = [ "dradis-plugins" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15ysf270wx34x5narff16hsv8ha8m30fryiv8jn15m6k81l68xsp";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-coreimpact = {
    dependencies = [ "dradis-plugins" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mjz7ir8szfi5s86jbzw6csc77hh22hawxv38k1r5pbm84y8hrx7";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-csv = {
    dependencies = [ "dradis-plugins" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17mq7vwmz70yqf2a14kh8m7bvz7931q2amvnya2f4c9d73yl02xj";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-csv_export = {
    dependencies = [ "dradis-plugins" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19w2h5s0cpwlmnw5bymbzyfjjfnwjc96xhj5xj6l1d6zskhq7z7f";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-html_export = {
    dependencies = [ "RedCloth" "dradis-plugins" "rails_autolink" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05ira9yimkbxd1n1cpfkxkfsclgm2ql25s1py7kpmzwpvnx30sf9";
      type = "gem";
    };
    version = "4.10.1";
  };
  dradis-metasploit = {
    dependencies = [ "dradis-plugins" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16ddd1k3l430rw3i8haz2pi9vr4gj79cj8y0jwrvnzl5qiw65v4y";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-nessus = {
    dependencies = [ "dradis-plugins" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1arpiswjy6vvfylb9pza1qdambbbb5rlwfcdcdlbpinlamkwdzby";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-netsparker = {
    dependencies = [ "dradis-plugins" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09721wdmg4124swrnhnzd0skps32pxy6v4d8dc5jgsaf0m82mgk7";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-nexpose = {
    dependencies = [ "dradis-plugins" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bjw4mb1m8pn3r1jbq4ck35q0il3c07zpyn4fd7q7li0lvra737v";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-nikto = {
    dependencies = [ "dradis-plugins" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ha35l505i0cws7xh6j10mwsmyv9s0rvspp9j0209632v821bfkw";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-nipper = {
    dependencies = [ "dradis-plugins" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vciv6gx57ddn1qbp9b60j02xgyk67lar11d2ywxnpa6s8icyyif";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-nmap = {
    dependencies = [ "dradis-plugins" "ruby-nmap" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z767m7cq1wi46w0pwcjkj7rbrqk37g709abj8y16np03y7jmsaa";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-ntospider = {
    dependencies = [ "dradis-plugins" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zbbkjjj10yy3bh1k4m1vqs9gk2vm8x7vjrks4cqkknszhva2vw1";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-openvas = {
    dependencies = [ "dradis-plugins" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ch6y1r65nsapcddalixxhyn53a6lm1ljw7vdw47aiky64acxqq9";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-plugins = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "081ck7qqw4bwa1908w4w7pbwmj6pi8nx60aby4vm11nmjmw28y6x";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-projects = {
    dependencies = [ "dradis-plugins" "rubyzip" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dz8vc4b3anbl4q6k9mpl1qplvjg0jf6wqdwnqn291xdrf5mp55n";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-qualys = {
    dependencies = [ "dradis-plugins" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x3a2lk1vkd07lwip5q8lvdvkh9dv1pxhi0jbkk29vxdjq5sq9k0";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-saint = {
    dependencies = [ "combustion" "dradis-plugins" "nokogiri" "rake" "rspec-rails" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ps6h44qdp59rmk0476jlrf7vg26m2f9043zbfb3nfc84zln9wya";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-veracode = {
    dependencies = [ "dradis-plugins" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lmif1pjapkf5plraphhqfqhhq1y9sn2y03d00wkspvvlrx2s2wb";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-wpscan = {
    dependencies = [ "dradis-plugins" "multi_json" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19md2viaq50p4928pv6aahsvlllsj039qgd9ha8mvmw2i4i7pfx1";
      type = "gem";
    };
    version = "4.10.0";
  };
  dradis-zap = {
    dependencies = [ "dradis-plugins" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19gshiqk1wjlv2d3av50igmzgp5wyv6ia58p3zyd6dg38cijk10h";
      type = "gem";
    };
    version = "4.10.0";
  };
  erubi = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08s75vs9cxlc4r1q2bjg4br8g9wc5lc5x5vl0vv4zq5ivxsdpgi7";
      type = "gem";
    };
    version = "1.12.0";
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
      sha256 = "1pfk942d6qwhw151hxaz7n4knk6whyxqvvywdx2cdw9yhykyaqzq";
      type = "gem";
    };
    version = "6.2.1";
  };
  factory_bot_rails = {
    dependencies = [ "factory_bot" "railties" ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18fhcihkc074gk62iwqgbdgc3ymim4fm0b4p3ipffy5hcsb9d2r7";
      type = "gem";
    };
    version = "6.2.0";
  };
  ffi = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15hgiy09i8ywjihyzyvjvk42ivi3kmy6dm21s5sgg9j7y3h3zkkx";
      type = "gem";
    };
    version = "1.14.2";
  };
  font-awesome-sass = {
    dependencies = [ "sassc" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nfjkgs9hijlmy929kdpahnxjhl3i1xl5vq9mbb1fpqg3fzkwvdr";
      type = "gem";
    };
    version = "6.4.0";
  };
  foreman = {
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "149sz75lk6d7bbsj9f849h6rnm94qadp76686a16vnpzxwssi0bz";
      type = "gem";
    };
    version = "0.87.0";
  };
  formatador = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gc26phrwlmlqrmz4bagq1wd5b7g64avpx0ghxr9xdxcvmlii0l0";
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
      sha256 = "0kqm5ndzaybpnpxqiqkc41k4ksyxl41ln8qqr6kb130cdxsf2dxk";
      type = "gem";
    };
    version = "1.1.0";
  };
  guard = {
    dependencies = [ "formatador" "listen" "lumberjack" "nenv" "notiffany" "pry" "shellany" "thor" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zw9zzf6ha9brj5qxn5fyw61gjcrw872d1qx11hd08dqrnsd4nx3";
      type = "gem";
    };
    version = "2.16.1";
  };
  guard-compat = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zj6sr1k8w59mmi27rsii0v8xyy2rnsi09nqvwpgj1q10yq1mlis";
      type = "gem";
    };
    version = "1.2.1";
  };
  guard-rspec = {
    dependencies = [ "guard" "guard-compat" "rspec" ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jkm5xp90gm4c5s51pmf92i9hc10gslwwic6mvk72g0yplya0yx4";
      type = "gem";
    };
    version = "4.7.3";
  };
  html-pipeline = {
    dependencies = [ "activesupport" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x5i330yks7pb1jxcbm9n6gslkgaqhyvl13d0cqxmxzkcajvb7z4";
      type = "gem";
    };
    version = "2.12.3";
  };
  i18n = {
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qaamqsh5f3szhcakkak8ikxlzxqnv49n2p7504hcz2l0f4nj0wx";
      type = "gem";
    };
    version = "1.14.1";
  };
  image_size = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ni3mm1pcjl8pnv0j91jghxdwmllx6xn3zy6n0x6xn4p1j435w2i";
      type = "gem";
    };
    version = "1.3.1";
  };
  jbuilder = {
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w5zrpfxaxlnq0ild80mbxz4w226l1gv0v1i51x6gy2sw1z69r0f";
      type = "gem";
    };
    version = "2.10.0";
  };
  jquery-fileupload-rails = {
    dependencies = [ "actionpack" "railties" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n09hvp6marjgwngj3gyya9yxxv133hwx2p5hw1xsq3k69c4crw3";
      type = "gem";
    };
    version = "0.3.5";
  };
  jquery-hotkeys-rails = {
    dependencies = [ "railties" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rrhld4zrkvlda97zxpd652rlhhqrvmqbx58mjybqp596cbnyfhr";
      type = "gem";
    };
    version = "0.7.9.1";
  };
  jquery-rails = {
    dependencies = [ "rails-dom-testing" "railties" "thor" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dkhm8lan1vnyl3ll0ks2q06576pdils8a1dr354vfc1y5dqw15i";
      type = "gem";
    };
    version = "4.4.0";
  };
  jquery-ui-rails = {
    dependencies = [ "railties" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mbwwbbwzp836l7mc21amnaqmf5wbrw5hzls48hscrcgh0vig812";
      type = "gem";
    };
    version = "6.0.1";
  };
  json = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nrmw2r4nfxlfgprfgki3hjifgrcrs3l5zvm3ca3gb4743yr25mn";
      type = "gem";
    };
    version = "2.3.0";
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
  kgio = {
    groups = [ "default" "production" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ipzvw7n0kz1w8rkqybyxvf3hb601a770khm0xdqm68mc4aa59xx";
      type = "gem";
    };
    version = "2.11.4";
  };
  launchy = {
    dependencies = [ "addressable" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "190lfbiy1vwxhbgn4nl4dcbzxvm049jwc158r2x7kq3g5khjrxa2";
      type = "gem";
    };
    version = "2.4.3";
  };
  letter_opener = {
    dependencies = [ "launchy" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09a7kgsmr10a0hrc9bwxglgqvppjxij9w8bxx91mnvh0ivaw0nq9";
      type = "gem";
    };
    version = "1.7.0";
  };
  libv8-node = {
    groups = [ "default" ];
    platforms = [{
      engine = "maglev";
    }
      {
        engine = "rbx";
      }
      {
        engine = "ruby";
      }];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "102ixp1626b4zjh98h3jxhwv0sdbkgijz38wyb1ffgxqr47c7s0w";
      type = "gem";
    };
    version = "16.10.0.0";
  };
  liquid = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n3jazcynk07p8vr9aylnixqsyrvnif7ahnr9qf59xmq4pvp2mvl";
      type = "gem";
    };
    version = "5.0.1";
  };
  listen = {
    dependencies = [ "rb-fsevent" "rb-inotify" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0imzd0cb9vlkc3yggl4rph1v1wm4z9psgs4z6aqsqa5hgf8gr9hj";
      type = "gem";
    };
    version = "3.4.1";
  };
  local_time = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1965297is1h2wzbaln5yawgzxnrpxf7v7qakmcrryjcvbmbkcdnd";
      type = "gem";
    };
    version = "2.1.0";
  };
  loofah = {
    dependencies = [ "crass" "nokogiri" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1p744kjpb5zk2ihklbykzii77alycjc04vpnm2ch2f3cp65imlj3";
      type = "gem";
    };
    version = "2.21.3";
  };
  lumberjack = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1m9ajfrs5ys3dp2glwbmyzfpd7qyz7dz49gz78is1yra0jawkm6d";
      type = "gem";
    };
    version = "1.2.4";
  };
  mail = {
    dependencies = [ "mini_mime" "net-imap" "net-pop" "net-smtp" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bf9pysw1jfgynv692hhaycfxa8ckay1gjw5hz3madrbrynryfzc";
      type = "gem";
    };
    version = "2.8.1";
  };
  marcel = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kky3yiwagsk8gfbzn3mvl2fxlh3b39v6nawzm4wpjs6xxvvc4x0";
      type = "gem";
    };
    version = "1.0.2";
  };
  matrix = {
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h2cgkpzkh3dd0flnnwfq6f3nl2b1zff9lvqz8xs853ssv5kq23i";
      type = "gem";
    };
    version = "0.4.2";
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
  mini_mime = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lbim375gw2dk6383qirz13hgdmxlan0vc5da2l072j3qw6fqjm5";
      type = "gem";
    };
    version = "1.1.2";
  };
  mini_portile2 = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z7f38iq37h376n9xbl4gajdrnwzq284c9v1py4imw3gri2d5cj6";
      type = "gem";
    };
    version = "2.8.2";
  };
  mini_racer = {
    dependencies = [ "libv8-node" ];
    groups = [ "default" ];
    platforms = [{
      engine = "maglev";
    }
      {
        engine = "rbx";
      }
      {
        engine = "ruby";
      }];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jf9qjz3r06asz14b6f3z7f2y437a1viqfp52sdi71ipj7dk70bs";
      type = "gem";
    };
    version = "0.6.2";
  };
  minitest = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kg9wh7jlc9zsr3hkhpzkbn0ynf4np5ap9m2d8xdrb8shy0y6pmb";
      type = "gem";
    };
    version = "5.18.1";
  };
  mono_logger = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0svj3sjd8cf1i15n6gdrp1n4rbzljb89vvp303f3zs9lz2r9glpr";
      type = "gem";
    };
    version = "1.1.1";
  };
  msgpack = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hpj9mm31a5aw5qys2kglfl8jv74bkwkc5pfrpp3als89hgkznqy";
      type = "gem";
    };
    version = "1.5.2";
  };
  multi_json = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pb1g1y3dsiahavspyzkdy39j4q377009f6ix0bh1ag4nqw43l0z";
      type = "gem";
    };
    version = "1.15.0";
  };
  mustermann = {
    dependencies = [ "ruby2_keywords" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m70qz27mlv2rhk4j1li6pw797gmiwwqg02vcgxcxr1rq2v53rnb";
      type = "gem";
    };
    version = "2.0.2";
  };
  nenv = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r97jzknll9bhd8yyg2bngnnkj8rjhal667n7d32h8h7ny7nvpnr";
      type = "gem";
    };
    version = "0.3.0";
  };
  net-imap = {
    dependencies = [ "date" "net-protocol" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k1qyjr9lkk5y3483k6wk6d9h1jx4v5hzby1mf0pj3b4kr2arxbm";
      type = "gem";
    };
    version = "0.3.6";
  };
  net-pop = {
    dependencies = [ "net-protocol" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wyz41jd4zpjn0v1xsf9j778qx1vfrl24yc20cpmph8k42c4x2w4";
      type = "gem";
    };
    version = "0.1.2";
  };
  net-protocol = {
    dependencies = [ "timeout" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dxckrlw4q1lcn3qg4mimmjazmg9bma5gllv72f8js3p36fb3b91";
      type = "gem";
    };
    version = "0.2.1";
  };
  net-smtp = {
    dependencies = [ "net-protocol" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c6md06hm5bf6rv53sk54dl2vg038pg8kglwv3rayx0vk2mdql9x";
      type = "gem";
    };
    version = "0.3.3";
  };
  nio4r = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w9978zwjf1qhy3amkivab0f9syz6a7k0xgydjidaf7xc831d78f";
      type = "gem";
    };
    version = "2.5.9";
  };
  nokogiri = {
    dependencies = [ "mini_portile2" "racc" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jw8a20a9k05fpz3q24im19b97idss3179z76yn5scc5b8lk2rl7";
      type = "gem";
    };
    version = "1.15.3";
  };
  notiffany = {
    dependencies = [ "nenv" "shellany" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f47h3bmg1apr4x51szqfv3rh2vq58z3grh4w02cp3bzbdh6jxnk";
      type = "gem";
    };
    version = "0.1.3";
  };
  paper_trail = {
    dependencies = [ "activerecord" "request_store" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12qvyhifm5xfdv4s6ry6zy166kwjwycg1lawzqf9qnhjxn986sl9";
      type = "gem";
    };
    version = "12.2.0";
  };
  parallel = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07vnk6bb54k4yc06xnwck7php50l09vvlw1ga8wdz0pia461zpzb";
      type = "gem";
    };
    version = "1.22.1";
  };
  parser = {
    dependencies = [ "ast" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q31n7yj59wka8xl8s5wkf66hm4pgvblx95czyxffprdnlhrir2p";
      type = "gem";
    };
    version = "3.1.2.1";
  };
  parslet = {
    dependencies = [ "blankslate" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fqd4p89zbyxpdjl4rm747qd6zd12r9h1zcqa5sd3ni18rzdf3d7";
      type = "gem";
    };
    version = "1.6.2";
  };
  pg = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wd6nl81nbdwck04hccsm7wf23ghpi8yddd9j4rbwyvyj0sbsff1";
      type = "gem";
    };
    version = "1.4.5";
  };
  popper_js = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07bibzk5lbqf73wlhdkx0qmxzj7xmkqamb8bqcilk0jhz3v6fy6v";
      type = "gem";
    };
    version = "2.11.7";
  };
  pry = {
    dependencies = [ "coderay" "method_source" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00rm71x0r1jdycwbs83lf9l6p494m99asakbvqxh8rz7zwnlzg69";
      type = "gem";
    };
    version = "0.12.2";
  };
  public_suffix = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xqcgkl7bwws1qrlnmxgh8g4g9m10vg60bhlw40fplninb3ng6d9";
      type = "gem";
    };
    version = "4.0.6";
  };
  puma = {
    dependencies = [ "nio4r" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yqv698njhwi5m8wc6smgszjswlv8ib94kkq5ih9apnsrraggzw9";
      type = "gem";
    };
    version = "5.6.7";
  };
  racc = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11v3l46mwnlzlc371wr3x6yylpgafgwdf0q7hc7c1lzx6r414r5g";
      type = "gem";
    };
    version = "1.7.1";
  };
  rack = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16w217k9z02c4hqizym8dkj6bqmmzx4qdvqpnskgzf174a5pwdxk";
      type = "gem";
    };
    version = "2.2.7";
  };
  rack-mini-profiler = {
    dependencies = [ "rack" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n28s6v33p7sdi32xgy7qsnn60b76mp75fcwgv09r4727abk46qk";
      type = "gem";
    };
    version = "2.3.0";
  };
  rack-protection = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08rcmwbnzs0km2dh4h1ngja0d921695rr2v155jiz3l1i7jqvssq";
      type = "gem";
    };
    version = "2.2.3";
  };
  rack-test = {
    dependencies = [ "rack" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ysx29gk9k14a14zsp5a8czys140wacvp91fja8xcja0j1hzqq8c";
      type = "gem";
    };
    version = "2.1.0";
  };
  rails = {
    dependencies = [ "actioncable" "actionmailbox" "actionmailer" "actionpack" "actiontext" "actionview" "activejob" "activemodel" "activerecord" "activestorage" "activesupport" "railties" "sprockets-rails" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gf5dqabzd0mf0q39a07kf0smdm2cv2z5swl3zr4cz50yb85zz3l";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  rails-dom-testing = {
    dependencies = [ "activesupport" "minitest" "nokogiri" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fx9dx1ag0s1lr6lfr34lbx5i1bvn3bhyf3w3mx6h7yz90p725g5";
      type = "gem";
    };
    version = "2.2.0";
  };
  rails-html-sanitizer = {
    dependencies = [ "loofah" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mcb75qvldfz6zsr4inrfx7dmb0ngxy507awx28khqmnla3hqpc9";
      type = "gem";
    };
    version = "1.4.4";
  };
  rails_autolink = {
    dependencies = [ "actionview" "activesupport" "railties" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fpwkc20bi7aynfgp2bqhvb7x6vsdiai4prflcsr9sicbwp9vjzv";
      type = "gem";
    };
    version = "1.1.8";
  };
  railties = {
    dependencies = [ "actionpack" "activesupport" "method_source" "rake" "thor" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vq4ahyg9hraixxmmwwypdnpcylpvznvdxhj4xa23xk45wzbl3h7";
      type = "gem";
    };
    version = "6.1.7.6";
  };
  rainbow = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      type = "gem";
    };
    version = "3.1.1";
  };
  raindrops = {
    groups = [ "default" "production" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wb2x51parf6v78w0cic90m33bdc92y5h8rj4wqs75dhw1b69hc7";
      type = "gem";
    };
    version = "0.20.0";
  };
  rake = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15whn7p9nrkxangbs9hh75q585yfn66lv0v2mhj6q6dl6x8bzr2w";
      type = "gem";
    };
    version = "13.0.6";
  };
  rb-fsevent = {
    groups = [ "default" "development" "test" ];
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
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jm76h8f8hji38z3ggf4bzi8vps6p7sagxn3ab57qc0xyga64005";
      type = "gem";
    };
    version = "0.10.1";
  };
  record_tag_helper = {
    dependencies = [ "actionview" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1krxbjqrhizn1fv6ffk05m3vbhd9qbjqrfk9d7wx0ag5q3v77c18";
      type = "gem";
    };
    version = "1.0.1";
  };
  RedCloth = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m9dv7ya9q93r8x1pg2gi15rxlbck8m178j1fz7r5v6wr1avrrqy";
      type = "gem";
    };
    version = "4.3.2";
  };
  redis = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w5j8666zz2cdg342g16cyr9rbm0ljgs2adygl8bnf22zq3fvir4";
      type = "gem";
    };
    version = "4.7.0";
  };
  redis-namespace = {
    dependencies = [ "redis" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ndj4lcm8rw01078zr0249grsk93zbda8qsibdvlx69b5ijg1rzf";
      type = "gem";
    };
    version = "1.8.2";
  };
  regexp_parser = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vg7imjnfcqjx7kw94ccj5r78j4g190cqzi1i59sh4a0l940b9cr";
      type = "gem";
    };
    version = "2.1.1";
  };
  request_store = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13ppgmsbrqah08j06bybd3cddv6dml79yzyjn7r8j1src78h98h7";
      type = "gem";
    };
    version = "1.5.1";
  };
  rerun = {
    dependencies = [ "listen" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cskvxk8z8vmfail8na7hj91hs0qnvds9nydj04zi3dbddgnbmvz";
      type = "gem";
    };
    version = "0.13.0";
  };
  resque = {
    dependencies = [ "mono_logger" "multi_json" "redis-namespace" "sinatra" "vegas" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "018x746l1nfkbjs84xmagl193jlmq8xfvp66rw4ahpl12iriyz1q";
      type = "gem";
    };
    version = "1.27.4";
  };
  resque-status = {
    dependencies = [ "resque" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02vnxjr51fbkc5qzwmr6vq3zhmm0jsj8hr8ip7lj98ad89x8p3ka";
      type = "gem";
    };
    version = "0.5.0";
  };
  rexml = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08ximcyfjy94pm1rhcx04ny1vx2sk0x4y185gzn86yfsbzwkng53";
      type = "gem";
    };
    version = "3.2.5";
  };
  rinku = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zcdha17s1wzxyc5814j6319wqg33jbn58pg6wmxpws36476fq4b";
      type = "gem";
    };
    version = "2.0.6";
  };
  rprogram = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "103c2riyyf9jcv7r86w4byzdh2f6g9ji3s8m2avy905l4frp37ms";
      type = "gem";
    };
    version = "0.3.2";
  };
  rspec = {
    dependencies = [ "rspec-core" "rspec-expectations" "rspec-mocks" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dwai7jnwmdmd7ajbi2q0k0lx1dh88knv5wl7c34wjmf94yv8w5q";
      type = "gem";
    };
    version = "3.10.0";
  };
  rspec-core = {
    dependencies = [ "rspec-support" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06wmcjsslx9vmw0bair46551ya8mb76csjyb59fxsmnkkp75jmh0";
      type = "gem";
    };
    version = "3.10.2";
  };
  rspec-expectations = {
    dependencies = [ "diff-lcs" "rspec-support" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qrj2j9jcd3m4aksk4kbv439882yl3z1harv2jrybrgjgdzdz7zs";
      type = "gem";
    };
    version = "3.10.2";
  };
  rspec-mocks = {
    dependencies = [ "diff-lcs" "rspec-support" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02i64ihazgm2dp07y89q1m9pyk724g5n9l83cy21x6snnzcg7xnj";
      type = "gem";
    };
    version = "3.10.3";
  };
  rspec-rails = {
    dependencies = [ "actionpack" "activesupport" "railties" "rspec-core" "rspec-expectations" "rspec-mocks" "rspec-support" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0aw5knjij21kzwis3vkcmqc16p55lbig1wq0i37093qga7zfsdg1";
      type = "gem";
    };
    version = "4.0.2";
  };
  rspec-support = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pjckrh8q6sqxy38xw7f4ziylq1983k84xh927s6352pps68zj35";
      type = "gem";
    };
    version = "3.10.3";
  };
  rubocop = {
    dependencies = [ "json" "parallel" "parser" "rainbow" "regexp_parser" "rexml" "rubocop-ast" "ruby-progressbar" "unicode-display_width" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fhyia6fw438ld83vz7vx37zynmzv042saf04ir43ga6sxk4m9k4";
      type = "gem";
    };
    version = "1.38.0";
  };
  rubocop-ast = {
    dependencies = [ "parser" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qiq3q66w57im0ryrvnd1yq0g2s2safhywpv94441kvc1amayjzy";
      type = "gem";
    };
    version = "1.23.0";
  };
  ruby-nmap = {
    dependencies = [ "nokogiri" "rprogram" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "065cr0qsw4bmgc8v0c4irq2j25857b0grjyq3r6y27x3h3myzfs9";
      type = "gem";
    };
    version = "0.10.0";
  };
  ruby-progressbar = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02nmaw7yx9kl7rbaan5pl8x5nn0y4j5954mzrkzi9i3dhsrps4nc";
      type = "gem";
    };
    version = "1.11.0";
  };
  ruby2_keywords = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vz322p8n39hz3b4a9gkmz9y7a5jaz41zrm2ywf31dvkqm03glgz";
      type = "gem";
    };
    version = "0.0.5";
  };
  ruby_audit = {
    dependencies = [ "bundler-audit" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zcdls4mxigc5mgpadw892przflyblrns11v23vfcjcqxw7jnyxs";
      type = "gem";
    };
    version = "2.1.0";
  };
  rubyzip = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0grps9197qyxakbpw02pda59v45lfgbgiyw48i0mq9f2bn9y6mrz";
      type = "gem";
    };
    version = "2.3.2";
  };
  sanitize = {
    dependencies = [ "crass" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kymrjdpbmn4yaml3aaqyj1dzj8gqmm9h030dc2rj5mvja7fpi28";
      type = "gem";
    };
    version = "6.0.2";
  };
  sass-rails = {
    dependencies = [ "sassc-rails" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lqhb0fgmls9l9jhgz42ri25w13q5pmsiiwzjbarz4n7l6749dp0";
      type = "gem";
    };
    version = "6.0.0";
  };
  sassc = {
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gpqv48xhl8mb8qqhcifcp0pixn206a7imc07g48armklfqa4q2c";
      type = "gem";
    };
    version = "2.4.0";
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
  selenium-webdriver = {
    dependencies = [ "rexml" "rubyzip" "websocket" ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ws0mh230l1pvyxcrlcr48w01alfhprjs1jbd8yrn463drsr2yac";
      type = "gem";
    };
    version = "4.11.0";
  };
  shellany = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ryyzrj1kxmnpdzhlv4ys3dnl2r5r3d2rs2jwzbnd1v96a8pl4hf";
      type = "gem";
    };
    version = "0.0.1";
  };
  shoulda-matchers = {
    dependencies = [ "activesupport" ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19smdzb2w0xgk8zig3h527absqhd71cdf2bdikldyawbyfw57307";
      type = "gem";
    };
    version = "3.1.3";
  };
  simple_form = {
    dependencies = [ "actionpack" "activemodel" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z4df65w9qpri315lpvzazdxa9xb7yj0j3d77q06wf0jnpvw4mzs";
      type = "gem";
    };
    version = "5.2.0";
  };
  sinatra = {
    dependencies = [ "mustermann" "rack" "rack-protection" "tilt" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dv5c5n9lhncqmasklif5rs6rj29gfh0dypwhk1nzzrbs6yywn61";
      type = "gem";
    };
    version = "2.2.3";
  };
  spring = {
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x2wz1y2b0kp7mlk9k8zkl39rddk2l3x34b7dar3bh3axd1cs30d";
      type = "gem";
    };
    version = "2.1.1";
  };
  sprockets = {
    dependencies = [ "concurrent-ruby" "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k0236g4h3ax7v6vp9k0l2fa0w6f1wqp7dn060zm4isw4n3k89sw";
      type = "gem";
    };
    version = "4.2.0";
  };
  sprockets-rails = {
    dependencies = [ "actionpack" "activesupport" "sprockets" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b9i14qb27zs56hlcc2hf139l0ghbqnjpmfi0054dxycaxvk5min";
      type = "gem";
    };
    version = "3.4.2";
  };
  sqlite3 = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lja01cp9xd5m6vmx99zwn4r7s97r1w5cb76gqd8xhbm1wxyzf78";
      type = "gem";
    };
    version = "1.4.2";
  };
  terser = {
    dependencies = [ "execjs" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "119xpgl5s2m6h8wfacqzmrd6jxkasb1mfyabsl354ap4pr0q60k0";
      type = "gem";
    };
    version = "1.1.15";
  };
  thor = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k7j2wn14h1pl4smibasw0bp66kg626drxb59z7rzflch99cd4rg";
      type = "gem";
    };
    version = "1.2.2";
  };
  tilt = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "186nfbcsk0l4l86gvng1fw6jq6p6s7rc0caxr23b3pnbfb20y63v";
      type = "gem";
    };
    version = "2.0.11";
  };
  time = {
    dependencies = [ "date" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13pzdsgf3v06mymzipcpa7p80shyw328ybn775nzpnhc6n8y9g30";
      type = "gem";
    };
    version = "0.2.2";
  };
  timecop = {
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lvd1xhp2xfkanq3hhbibkbhnvlcgf31lsm5byfc2fsczcky707s";
      type = "gem";
    };
    version = "0.9.5";
  };
  timeout = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1d9cvm0f4zdpwa795v3zv4973y5zk59j7s1x3yn90jjrhcz1yvfd";
      type = "gem";
    };
    version = "0.4.0";
  };
  turbolinks = {
    dependencies = [ "turbolinks-source" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "176fbkhhi2jmsnbkcng2qr82nd35qmh3inmbv5dqm9z2qj4misjz";
      type = "gem";
    };
    version = "5.2.1";
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
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16w2g84dzaf3z13gxyzlzbf748kylk5bdgg3n1ipvkvvqy685bwd";
      type = "gem";
    };
    version = "2.0.6";
  };
  unicode-display_width = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ra70s8prfacpqwj5v2mqn1rbfz6xds3n9nsr9cwzs3z2c0wm5j7";
      type = "gem";
    };
    version = "2.3.0";
  };
  unicorn = {
    dependencies = [ "kgio" "raindrops" ];
    groups = [ "production" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h0gma14jjxiz6piyi6p99q7lya2mxrq79l03160hascvmx9ipa5";
      type = "gem";
    };
    version = "6.1.0";
  };
  vegas = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kzv0v1zb8vvm188q4pqwahb6468bmiamn6wpsbiq6r5i69s1bs5";
      type = "gem";
    };
    version = "0.1.11";
  };
  warden = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fr9n9i9r82xb6i61fdw4xgc7zjv7fsdrr4k0njchy87iw9fl454";
      type = "gem";
    };
    version = "1.2.8";
  };
  web-console = {
    dependencies = [ "actionview" "activemodel" "bindex" "railties" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d9hk929cmisix2l1w9kkh05b57ih9yvnh4wv52axxw41scnv2d9";
      type = "gem";
    };
    version = "4.1.0";
  };
  websocket = {
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dib6p55sl606qb4vpwrvj5wh881kk4aqn2zpfapf8ckx7g14jw8";
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
      sha256 = "1nyh873w4lvahcl8kzbjfca26656d5c6z3md4sbqg5y1gfz0157n";
      type = "gem";
    };
    version = "0.7.6";
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
  whenever = {
    dependencies = [ "chronic" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0im2x9rgr752hb9f1nnfj486k96bfiqj0xsv2bmzaq1rqhbi9dyr";
      type = "gem";
    };
    version = "1.0.0";
  };
  xpath = {
    dependencies = [ "nokogiri" ];
    groups = [ "default" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bh8lk9hvlpn7vmi6h4hkcwjzvs2y0cmkk3yjjdr8fxvj6fsgzbd";
      type = "gem";
    };
    version = "3.2.0";
  };
  zeitwerk = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mwdd445w63khz13hpv17m2br5xngyjl3jdj08xizjbm78i2zrxd";
      type = "gem";
    };
    version = "2.6.11";
  };
}
