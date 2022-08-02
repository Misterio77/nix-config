{ fetchurl, composerEnv }:

{
  packages = {
    "amphp/amp" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "amphp-amp-9d5100cebffa729aaffecd3ad25dc5aeea4f13bb";
        src = fetchurl {
          url = "https://api.github.com/repos/amphp/amp/zipball/9d5100cebffa729aaffecd3ad25dc5aeea4f13bb";
          sha256 = "0pwk9xx2wr5h0lyihccinvzlkk17hc4gjc0w5jsinxsnazfqhmn1";
        };
      };
    };
    "amphp/byte-stream" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "amphp-byte-stream-acbd8002b3536485c997c4e019206b3f10ca15bd";
        src = fetchurl {
          url = "https://api.github.com/repos/amphp/byte-stream/zipball/acbd8002b3536485c997c4e019206b3f10ca15bd";
          sha256 = "14jqc5igivq54bwj0gr9rpbnw1rapi11ddhmvbkx1251a1bbyzr2";
        };
      };
    };
    "amphp/cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "amphp-cache-2b6b5dbb70e54cc914df9952ba7c012bc4cbcd28";
        src = fetchurl {
          url = "https://api.github.com/repos/amphp/cache/zipball/2b6b5dbb70e54cc914df9952ba7c012bc4cbcd28";
          sha256 = "0ph57sarmqihnnqlsffjf6ajihgk2sq9zq4vyrfbz3jshqikwm71";
        };
      };
    };
    "amphp/dns" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "amphp-dns-852292532294d7972c729a96b49756d781f7c59d";
        src = fetchurl {
          url = "https://api.github.com/repos/amphp/dns/zipball/852292532294d7972c729a96b49756d781f7c59d";
          sha256 = "1l2k427x51an2y7531vcw0gbs3gxvm5ni8b82ahnxq71h36js5bk";
        };
      };
    };
    "amphp/parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "amphp-parser-f83e68f03d5b8e8e0365b8792985a7f341c57ae1";
        src = fetchurl {
          url = "https://api.github.com/repos/amphp/parser/zipball/f83e68f03d5b8e8e0365b8792985a7f341c57ae1";
          sha256 = "1qda6falmlgwvwcrbczzxalq6mhvmls5grzpzr5saf84107dn6j7";
        };
      };
    };
    "amphp/process" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "amphp-process-76e9495fd6818b43a20167cb11d8a67f7744ee0f";
        src = fetchurl {
          url = "https://api.github.com/repos/amphp/process/zipball/76e9495fd6818b43a20167cb11d8a67f7744ee0f";
          sha256 = "1v40r55d29gvmgzx5ljdsb1g6wfdvjjlsjwzs7zhh8i6sl2r57p8";
        };
      };
    };
    "amphp/serialization" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "amphp-serialization-693e77b2fb0b266c3c7d622317f881de44ae94a1";
        src = fetchurl {
          url = "https://api.github.com/repos/amphp/serialization/zipball/693e77b2fb0b266c3c7d622317f881de44ae94a1";
          sha256 = "14mx5540f1z672fkszdc5qcdz370i3q7w0kdl87aimzj87r3awkx";
        };
      };
    };
    "amphp/socket" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "amphp-socket-a8af9f5d0a66c5fe9567da45a51509e592788fe6";
        src = fetchurl {
          url = "https://api.github.com/repos/amphp/socket/zipball/a8af9f5d0a66c5fe9567da45a51509e592788fe6";
          sha256 = "0aapwq1jz2dvc638cpfp12n4fgwmlcrlrqbkrm6prxdbzh2yaiwv";
        };
      };
    };
    "amphp/sync" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "amphp-sync-85ab06764f4f36d63b1356b466df6111cf4b89cf";
        src = fetchurl {
          url = "https://api.github.com/repos/amphp/sync/zipball/85ab06764f4f36d63b1356b466df6111cf4b89cf";
          sha256 = "1ffl60c6pj1bg74fipyj16irhlj6356bc5nnkdmv7qrli212f800";
        };
      };
    };
    "amphp/windows-registry" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "amphp-windows-registry-0f56438b9197e224325e88f305346f0221df1f71";
        src = fetchurl {
          url = "https://api.github.com/repos/amphp/windows-registry/zipball/0f56438b9197e224325e88f305346f0221df1f71";
          sha256 = "1vv8xik6swpy12c5nzgfwrnjm92ay7v8vlwjw3wq0vjlrrkjw0jq";
        };
      };
    };
    "brick/math" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "brick-math-ca57d18f028f84f777b2168cd1911b0dee2343ae";
        src = fetchurl {
          url = "https://api.github.com/repos/brick/math/zipball/ca57d18f028f84f777b2168cd1911b0dee2343ae";
          sha256 = "1nr1grrb9g5g3ihx94yk0amp8zx8prkkvg2934ygfc3rrv03cq9w";
        };
      };
    };
    "composer/package-versions-deprecated" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "composer-package-versions-deprecated-b4f54f74ef3453349c24a845d22392cd31e65f1d";
        src = fetchurl {
          url = "https://api.github.com/repos/composer/package-versions-deprecated/zipball/b4f54f74ef3453349c24a845d22392cd31e65f1d";
          sha256 = "1hrjxvk8i14pw9gi7j3qc0gljjy74hwdkv8zwsrg5brgyzhqfwam";
        };
      };
    };
    "composer/pcre" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "composer-pcre-67a32d7d6f9f560b726ab25a061b38ff3a80c560";
        src = fetchurl {
          url = "https://api.github.com/repos/composer/pcre/zipball/67a32d7d6f9f560b726ab25a061b38ff3a80c560";
          sha256 = "0ignkzar4axidvfajnzd46wqgk958zms0apvkkkp72dp8njg6p81";
        };
      };
    };
    "composer/xdebug-handler" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "composer-xdebug-handler-9e36aeed4616366d2b690bdce11f71e9178c579a";
        src = fetchurl {
          url = "https://api.github.com/repos/composer/xdebug-handler/zipball/9e36aeed4616366d2b690bdce11f71e9178c579a";
          sha256 = "17aaq6d9y352kp8fm58widmljbwq4vj9pvdl0bldxflw0pf828j8";
        };
      };
    };
    "dantleech/argument-resolver" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dantleech-argument-resolver-e34fabf7d6e53e5194f745ad069c4a87cc4b34cc";
        src = fetchurl {
          url = "https://gitlab.com/api/v4/projects/dantleech%2Fargument-resolver/repository/archive.zip?sha=e34fabf7d6e53e5194f745ad069c4a87cc4b34cc";
          sha256 = "023hap8ikywq34j95xpb405hpi1fj9yp5za9a8ky9il87kdhsvnb";
        };
      };
    };
    "dantleech/invoke" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dantleech-invoke-9b002d746d2c1b86cfa63a47bb5909cee58ef50c";
        src = fetchurl {
          url = "https://api.github.com/repos/dantleech/invoke/zipball/9b002d746d2c1b86cfa63a47bb5909cee58ef50c";
          sha256 = "165vlqj5rf33gwvgc7674qxc12kqbpi7dqbzcdr87d4v6vi99w9n";
        };
      };
    };
    "dantleech/object-renderer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dantleech-object-renderer-942ad54a22e5ffb9ac3421d7bb06fa76bc45ad30";
        src = fetchurl {
          url = "https://api.github.com/repos/dantleech/object-renderer/zipball/942ad54a22e5ffb9ac3421d7bb06fa76bc45ad30";
          sha256 = "1m3dgyq1bs8xgffawdl3yij9zq9bcv6xay18p9zi9zq9wxawpzwj";
        };
      };
    };
    "daverandom/libdns" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "daverandom-libdns-e8b6d6593d18ac3a6a14666d8a68a4703b2e05f9";
        src = fetchurl {
          url = "https://api.github.com/repos/DaveRandom/LibDNS/zipball/e8b6d6593d18ac3a6a14666d8a68a4703b2e05f9";
          sha256 = "0l84mrkmm5w2cpkxvacm31vmv7pbz4dyxs5fj1rjfvbrhs0c2x03";
        };
      };
    };
    "dnoegel/php-xdg-base-dir" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dnoegel-php-xdg-base-dir-8f8a6e48c5ecb0f991c2fdcf5f154a47d85f9ffd";
        src = fetchurl {
          url = "https://api.github.com/repos/dnoegel/php-xdg-base-dir/zipball/8f8a6e48c5ecb0f991c2fdcf5f154a47d85f9ffd";
          sha256 = "02n4b4wkwncbqiz8mw2rq35flkkhn7h6c0bfhjhs32iay1y710fq";
        };
      };
    };
    "jetbrains/phpstorm-stubs" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "jetbrains-phpstorm-stubs-fcd660e2dbdcb04aa32a635a5d1fedb172d12db9";
        src = fetchurl {
          url = "https://api.github.com/repos/JetBrains/phpstorm-stubs/zipball/fcd660e2dbdcb04aa32a635a5d1fedb172d12db9";
          sha256 = "0ck414hhgs7mpxf59n8gdsbljpw498xqwq4vp02s1ac9ln4wh21d";
        };
      };
    };
    "kelunik/certificate" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "kelunik-certificate-56542e62d51533d04d0a9713261fea546bff80f6";
        src = fetchurl {
          url = "https://api.github.com/repos/kelunik/certificate/zipball/56542e62d51533d04d0a9713261fea546bff80f6";
          sha256 = "049izah872vw9rd5zydfy7hfpn2lwpn0jqpjw7xwzmabyv74d6kf";
        };
      };
    };
    "league/uri-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-uri-parser-671548427e4c932352d9b9279fdfa345bf63fa00";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/uri-parser/zipball/671548427e4c932352d9b9279fdfa345bf63fa00";
          sha256 = "1vqvk7npgipdd0ldmpj78pk63wwqlnwjcn61w695jv9sdfyw0c8n";
        };
      };
    };
    "microsoft/tolerant-php-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "microsoft-tolerant-php-parser-6a965617cf484355048ac6d2d3de7b6ec93abb16";
        src = fetchurl {
          url = "https://api.github.com/repos/microsoft/tolerant-php-parser/zipball/6a965617cf484355048ac6d2d3de7b6ec93abb16";
          sha256 = "1cv59r3r7qgl1s66yixifzyy32w8gp7f03m0rw74pfr8rdh4fqkx";
        };
      };
    };
    "monolog/monolog" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "monolog-monolog-904713c5929655dc9b97288b69cfeedad610c9a1";
        src = fetchurl {
          url = "https://api.github.com/repos/Seldaek/monolog/zipball/904713c5929655dc9b97288b69cfeedad610c9a1";
          sha256 = "17fjd5dk45b6dbfx15vxqk6mnm3fsn2kd8nsjfjd2zk3zfihq4jj";
        };
      };
    };
    "phpactor/amp-fswatch" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpactor-amp-fswatch-e40b7dc1b96c5fdb5c6598a9abe9ca846039cdf1";
        src = fetchurl {
          url = "https://api.github.com/repos/phpactor/amp-fswatch/zipball/e40b7dc1b96c5fdb5c6598a9abe9ca846039cdf1";
          sha256 = "0x31612vgc2528jrcj54zn125ad5sl3m4m2rnamv4b8mp0drf577";
        };
      };
    };
    "phpactor/class-to-file" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpactor-class-to-file-e9b70229f9e705eaeb7b476e37d1113888c30ad5";
        src = fetchurl {
          url = "https://api.github.com/repos/phpactor/class-to-file/zipball/e9b70229f9e705eaeb7b476e37d1113888c30ad5";
          sha256 = "1dd5zif9xin4w3k2ac29cs4rgnm9lw6n72af7j2l0wgzgj2hnnqa";
        };
      };
    };
    "phpactor/container" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpactor-container-61608993ac39ee7e45943f1b8f050c68e3ead515";
        src = fetchurl {
          url = "https://api.github.com/repos/phpactor/container/zipball/61608993ac39ee7e45943f1b8f050c68e3ead515";
          sha256 = "07cniyagcvzz7z9gaarabpbpnp4wgbnznm83k1s9svx5wprd0bv1";
        };
      };
    };
    "phpactor/language-server" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpactor-language-server-094d6fc2f31160840f8962158dd9b51d0f588c6e";
        src = fetchurl {
          url = "https://api.github.com/repos/phpactor/language-server/zipball/094d6fc2f31160840f8962158dd9b51d0f588c6e";
          sha256 = "076s4nfgmgyv56wmnn8bww3w12frvm86axcjvn6plfmik065ix3v";
        };
      };
    };
    "phpactor/language-server-protocol" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpactor-language-server-protocol-306dd561711833f2a05a63b8332dc717d7ea5001";
        src = fetchurl {
          url = "https://api.github.com/repos/phpactor/language-server-protocol/zipball/306dd561711833f2a05a63b8332dc717d7ea5001";
          sha256 = "0kxzsnn3509rhvkfcqpv9h4m1xfyrswyy6xnikbwbzj3zk006cc2";
        };
      };
    };
    "phpactor/map-resolver" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpactor-map-resolver-091c3e9233099126bed12b51dd545d05dda53163";
        src = fetchurl {
          url = "https://api.github.com/repos/phpactor/map-resolver/zipball/091c3e9233099126bed12b51dd545d05dda53163";
          sha256 = "0663r7089ixzcmjlz07rxs9l0wrh8j4nbw5qd0xf2lgm3lq4gdbp";
        };
      };
    };
    "phpactor/phly-event-dispatcher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpactor-phly-event-dispatcher-5519ac1a5df8a1db72df82e11367b23443f2a0fe";
        src = fetchurl {
          url = "https://api.github.com/repos/phpactor/phly-event-dispatcher/zipball/5519ac1a5df8a1db72df82e11367b23443f2a0fe";
          sha256 = "1y8j5c1plmwbfyjja95fl721jf8r7lbivqa6m8hmi2s9hql3bx4n";
        };
      };
    };
    "psr/container" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-container-513e0666f7216c7459170d56df27dfcefe1689ea";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/container/zipball/513e0666f7216c7459170d56df27dfcefe1689ea";
          sha256 = "00yvj3b5ls2l1d0sk38g065raw837rw65dx1sicggjnkr85vmfzz";
        };
      };
    };
    "psr/event-dispatcher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-event-dispatcher-dbefd12671e8a14ec7f180cab83036ed26714bb0";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/event-dispatcher/zipball/dbefd12671e8a14ec7f180cab83036ed26714bb0";
          sha256 = "05nicsd9lwl467bsv4sn44fjnnvqvzj1xqw2mmz9bac9zm66fsjd";
        };
      };
    };
    "psr/log" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-log-d49695b909c3b7628b6289db5479a1c204601f11";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/log/zipball/d49695b909c3b7628b6289db5479a1c204601f11";
          sha256 = "0sb0mq30dvmzdgsnqvw3xh4fb4bqjncx72kf8n622f94dd48amln";
        };
      };
    };
    "ramsey/collection" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ramsey-collection-cccc74ee5e328031b15640b51056ee8d3bb66c0a";
        src = fetchurl {
          url = "https://api.github.com/repos/ramsey/collection/zipball/cccc74ee5e328031b15640b51056ee8d3bb66c0a";
          sha256 = "1i2ga25aj80cci3di58qm17l588lzgank8wqhdbq0dcb3cg6cgr6";
        };
      };
    };
    "ramsey/uuid" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ramsey-uuid-fc9bb7fb5388691fd7373cd44dcb4d63bbcf24df";
        src = fetchurl {
          url = "https://api.github.com/repos/ramsey/uuid/zipball/fc9bb7fb5388691fd7373cd44dcb4d63bbcf24df";
          sha256 = "1fhjsyidsj95x5dd42z3hi5qhzii0hhhxa7xvc5jj7spqjdbqln4";
        };
      };
    };
    "sebastian/diff" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-diff-3461e3fccc7cfdfc2720be910d3bd73c69be590d";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/diff/zipball/3461e3fccc7cfdfc2720be910d3bd73c69be590d";
          sha256 = "0967nl6cdnr0v0z83w4xy59agn60kfv8gb41aw3fpy1n2wpp62dj";
        };
      };
    };
    "symfony/console" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-console-4d671ab4ddac94ee439ea73649c69d9d200b5000";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/console/zipball/4d671ab4ddac94ee439ea73649c69d9d200b5000";
          sha256 = "13p16qi328f7jds94vh2gswpq2zgkh99zr7x0ihvy9ysmdc4vln2";
        };
      };
    };
    "symfony/deprecation-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-deprecation-contracts-e8b495ea28c1d97b5e0c121748d6f9b53d075c66";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/deprecation-contracts/zipball/e8b495ea28c1d97b5e0c121748d6f9b53d075c66";
          sha256 = "09k869asjb7cd3xh8i5ps824k5y6v510sbpzfalndwy3knig9fig";
        };
      };
    };
    "symfony/filesystem" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-filesystem-36a017fa4cce1eff1b8e8129ff53513abcef05ba";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/filesystem/zipball/36a017fa4cce1eff1b8e8129ff53513abcef05ba";
          sha256 = "1f10w4f2pi3xnxcvn0ykf86i9d28ccvq6gi9qqlm7qbws7kpcn2i";
        };
      };
    };
    "symfony/polyfill-ctype" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-ctype-6fd1b9a79f6e3cf65f9e679b23af304cd9e010d4";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-ctype/zipball/6fd1b9a79f6e3cf65f9e679b23af304cd9e010d4";
          sha256 = "18235xiqpjx9nzx3pzylm5yzqr6n1j8wnnrzgab1hpbvixfrbqba";
        };
      };
    };
    "symfony/polyfill-intl-grapheme" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-intl-grapheme-433d05519ce6990bf3530fba6957499d327395c2";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-intl-grapheme/zipball/433d05519ce6990bf3530fba6957499d327395c2";
          sha256 = "11169jh39mhr591b61iara8hvq4pnfzgkynlqg90iv510c74d1cg";
        };
      };
    };
    "symfony/polyfill-intl-normalizer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-intl-normalizer-219aa369ceff116e673852dce47c3a41794c14bd";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-intl-normalizer/zipball/219aa369ceff116e673852dce47c3a41794c14bd";
          sha256 = "1cwckrazq4p4i9ysjh8wjqw8qfnp0rx48pkwysch6z7vkgcif22w";
        };
      };
    };
    "symfony/polyfill-mbstring" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-mbstring-9344f9cb97f3b19424af1a21a3b0e75b0a7d8d7e";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-mbstring/zipball/9344f9cb97f3b19424af1a21a3b0e75b0a7d8d7e";
          sha256 = "0y289x91c9lgr8vlixj5blayf9lsgi4nn2gyn3a99brvn2jnh6q8";
        };
      };
    };
    "symfony/polyfill-php72" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php72-bf44a9fd41feaac72b074de600314a93e2ae78e2";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php72/zipball/bf44a9fd41feaac72b074de600314a93e2ae78e2";
          sha256 = "11knb688wcf8yvrprgp4z02z3nb6s5xj3wrv77n2qjkc7nc8q7l7";
        };
      };
    };
    "symfony/polyfill-php73" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php73-e440d35fa0286f77fb45b79a03fedbeda9307e85";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php73/zipball/e440d35fa0286f77fb45b79a03fedbeda9307e85";
          sha256 = "1c7w7j375a1fxq5m4ldy72jg5x4dpijs8q9ryqxvd6gmj1lvncqy";
        };
      };
    };
    "symfony/polyfill-php80" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php80-cfa0ae98841b9e461207c13ab093d76b0fa7bace";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php80/zipball/cfa0ae98841b9e461207c13ab093d76b0fa7bace";
          sha256 = "1kbh4j01kxxc39ls9kzkg7dj13cdlzwy599b96harisysn47jw2n";
        };
      };
    };
    "symfony/polyfill-php81" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php81-13f6d1271c663dc5ae9fb843a8f16521db7687a1";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php81/zipball/13f6d1271c663dc5ae9fb843a8f16521db7687a1";
          sha256 = "01dqzkdppaw7kh1vkckkzn54aql4iw6m9vyg99ahhzmqc2krs91x";
        };
      };
    };
    "symfony/process" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-process-597f3fff8e3e91836bb0bd38f5718b56ddbde2f3";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/process/zipball/597f3fff8e3e91836bb0bd38f5718b56ddbde2f3";
          sha256 = "1vv2xwk3cvr144yxjj6k4afhkv50v2b957lscncs6m3rvi2zs1nk";
        };
      };
    };
    "symfony/service-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-service-contracts-4b426aac47d6427cc1a1d0f7e2ac724627f5966c";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/service-contracts/zipball/4b426aac47d6427cc1a1d0f7e2ac724627f5966c";
          sha256 = "0lh0vxy0h4wsjmnlf42s950bicsvkzz6brqikfnfb5kmvi0xhcm6";
        };
      };
    };
    "symfony/string" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-string-4432bc7df82a554b3e413a8570ce2fea90e94097";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/string/zipball/4432bc7df82a554b3e413a8570ce2fea90e94097";
          sha256 = "08abxmddl3nphkqf6a58r8w1d5la2f3m9rkbhdfv2k78h2nn19v7";
        };
      };
    };
    "symfony/yaml" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-yaml-04e42926429d9e8b39c174387ab990bf7817f7a2";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/yaml/zipball/04e42926429d9e8b39c174387ab990bf7817f7a2";
          sha256 = "13y7mrvfwrhj6lfvbmv5267pfa0rnba6v1h59sakr3zprkawpadb";
        };
      };
    };
    "thecodingmachine/safe" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "thecodingmachine-safe-a8ab0876305a4cdaef31b2350fcb9811b5608dbc";
        src = fetchurl {
          url = "https://api.github.com/repos/thecodingmachine/safe/zipball/a8ab0876305a4cdaef31b2350fcb9811b5608dbc";
          sha256 = "1l6n5gixh8ahs8bzbpjzixfm8g93vy9hzvivvivs332h85n3p96s";
        };
      };
    };
    "twig/twig" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "twig-twig-3b7cedb2f736899a7dbd0ba3d6da335a015f5cc4";
        src = fetchurl {
          url = "https://api.github.com/repos/twigphp/Twig/zipball/3b7cedb2f736899a7dbd0ba3d6da335a015f5cc4";
          sha256 = "1r3287ih85lgwnsmmbrfs4j0plr1g39dzjhfprj1ka7i6whbliqn";
        };
      };
    };
    "webmozart/assert" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "webmozart-assert-11cb2199493b2f8a3b53e7f19068fc6aac760991";
        src = fetchurl {
          url = "https://api.github.com/repos/webmozarts/assert/zipball/11cb2199493b2f8a3b53e7f19068fc6aac760991";
          sha256 = "18qiza1ynwxpi6731jx1w5qsgw98prld1lgvfk54z92b1nc7psix";
        };
      };
    };
    "webmozart/glob" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "webmozart-glob-3c17f7dec3d9d0e87b575026011f2e75a56ed655";
        src = fetchurl {
          url = "https://api.github.com/repos/webmozarts/glob/zipball/3c17f7dec3d9d0e87b575026011f2e75a56ed655";
          sha256 = "1rdngm6yfxapxxp5fcsmspsj3jpww18h1q6cl3qd1pi0ma8dyc6f";
        };
      };
    };
    "webmozart/path-util" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "webmozart-path-util-d939f7edc24c9a1bb9c0dee5cb05d8e859490725";
        src = fetchurl {
          url = "https://api.github.com/repos/webmozart/path-util/zipball/d939f7edc24c9a1bb9c0dee5cb05d8e859490725";
          sha256 = "0zv2di0fh3aiwij0nl6595p8qvm9zh0k8jd3ngqhmqnis35kr01l";
        };
      };
    };
  };
  devPackages = {
    "blackfire/php-sdk" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "blackfire-php-sdk-cec036e106d349d66db565c172ffc8f4beece6ae";
        src = fetchurl {
          url = "https://api.github.com/repos/blackfireio/php-sdk/zipball/cec036e106d349d66db565c172ffc8f4beece6ae";
          sha256 = "052k0iyr7ygz5lvjy493f9i5bawrn75rh17ppdjg9jaj8q3bvsw2";
        };
      };
    };
    "composer/ca-bundle" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "composer-ca-bundle-30897edbfb15e784fe55587b4f73ceefd3c4d98c";
        src = fetchurl {
          url = "https://api.github.com/repos/composer/ca-bundle/zipball/30897edbfb15e784fe55587b4f73ceefd3c4d98c";
          sha256 = "169w5h327dnzfdb0b594vnyqg991dfcpsix2hf12w5dqp3lnn3qc";
        };
      };
    };
    "composer/semver" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "composer-semver-3953f23262f2bff1919fc82183ad9acb13ff62c9";
        src = fetchurl {
          url = "https://api.github.com/repos/composer/semver/zipball/3953f23262f2bff1919fc82183ad9acb13ff62c9";
          sha256 = "0sp54hzb2gq777rd0w5ciq00g0l85irc2m6s2zx7675g24wfbbms";
        };
      };
    };
    "dantleech/what-changed" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dantleech-what-changed-d9d9fa1d1bf6f0f01a7f4ce8e0cdb61430d1251e";
        src = fetchurl {
          url = "https://api.github.com/repos/dantleech/what-changed/zipball/d9d9fa1d1bf6f0f01a7f4ce8e0cdb61430d1251e";
          sha256 = "1gng3afivgjapzvgcf96c0kg86rzqr4820dm96f9lql3bma8rlql";
        };
      };
    };
    "dms/phpunit-arraysubset-asserts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dms-phpunit-arraysubset-asserts-a54c72da11d6ec0b875514aae6f43e1315bfb8fa";
        src = fetchurl {
          url = "https://api.github.com/repos/rdohms/phpunit-arraysubset-asserts/zipball/a54c72da11d6ec0b875514aae6f43e1315bfb8fa";
          sha256 = "08l2ipkp26c7iwpqks1s6cghvdc7lbzifa6w5k1cnwndai08zzcz";
        };
      };
    };
    "doctrine/annotations" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-annotations-648b0343343565c4a056bfc8392201385e8d89f0";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/annotations/zipball/648b0343343565c4a056bfc8392201385e8d89f0";
          sha256 = "0mkxq1yaqp6an2gjcgsmg7hq37mrwcj27f94sfkfxq9x6qh02k57";
        };
      };
    };
    "doctrine/instantiator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-instantiator-10dcfce151b967d20fde1b34ae6640712c3891bc";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/instantiator/zipball/10dcfce151b967d20fde1b34ae6640712c3891bc";
          sha256 = "1m6pw3bb8v04wqsysj8ma4db8vpm9jnd7ddh8ihdqyfpz8pawjp7";
        };
      };
    };
    "doctrine/lexer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-lexer-c268e882d4dbdd85e36e4ad69e02dc284f89d229";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/lexer/zipball/c268e882d4dbdd85e36e4ad69e02dc284f89d229";
          sha256 = "12g069nljl3alyk15884nd1jc4mxk87isqsmfj7x6j2vxvk9qchs";
        };
      };
    };
    "felixfbecker/advanced-json-rpc" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "felixfbecker-advanced-json-rpc-b5f37dbff9a8ad360ca341f3240dc1c168b45447";
        src = fetchurl {
          url = "https://api.github.com/repos/felixfbecker/php-advanced-json-rpc/zipball/b5f37dbff9a8ad360ca341f3240dc1c168b45447";
          sha256 = "1414k12bznhi6zbb41sm7m2wjnpabvi1xybh0v6rxf8khj15rccq";
        };
      };
    };
    "felixfbecker/language-server-protocol" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "felixfbecker-language-server-protocol-6e82196ffd7c62f7794d778ca52b69feec9f2842";
        src = fetchurl {
          url = "https://api.github.com/repos/felixfbecker/php-language-server-protocol/zipball/6e82196ffd7c62f7794d778ca52b69feec9f2842";
          sha256 = "0gildnl5ciiq3sv23l2j6zrcf3glab56vvr4sxlwsd6pqzz2yl37";
        };
      };
    };
    "friendsofphp/php-cs-fixer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "friendsofphp-php-cs-fixer-47177af1cfb9dab5d1cc4daf91b7179c2efe7fad";
        src = fetchurl {
          url = "https://api.github.com/repos/FriendsOfPHP/PHP-CS-Fixer/zipball/47177af1cfb9dab5d1cc4daf91b7179c2efe7fad";
          sha256 = "1xf6rrwn5f14b5m9lpkj35v7a29vgf95dniwak2brwpmir8dpzag";
        };
      };
    };
    "jangregor/phpstan-prophecy" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "jangregor-phpstan-prophecy-2bc7ca9460395690c6bf7332bdfb2f25d5cae8e0";
        src = fetchurl {
          url = "https://api.github.com/repos/Jan0707/phpstan-prophecy/zipball/2bc7ca9460395690c6bf7332bdfb2f25d5cae8e0";
          sha256 = "0y1qhwlg3csbyxl0608w7f02l28f9acbdkg634xik1qdz5cpyjm9";
        };
      };
    };
    "myclabs/deep-copy" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "myclabs-deep-copy-14daed4296fae74d9e3201d2c4925d1acb7aa614";
        src = fetchurl {
          url = "https://api.github.com/repos/myclabs/DeepCopy/zipball/14daed4296fae74d9e3201d2c4925d1acb7aa614";
          sha256 = "11593chczjw8k5jix2mj9v31lg5jgpxqrkhp27bxd96aajapqd9w";
        };
      };
    };
    "netresearch/jsonmapper" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "netresearch-jsonmapper-8bbc021a8edb2e4a7ea2f8ad4fa9ec9dce2fcb8d";
        src = fetchurl {
          url = "https://api.github.com/repos/cweiske/jsonmapper/zipball/8bbc021a8edb2e4a7ea2f8ad4fa9ec9dce2fcb8d";
          sha256 = "0pfxhp5nmmk5jsz85ag6b29ryn68kn8j5g5w8x8cggpfadq35ga8";
        };
      };
    };
    "nikic/php-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nikic-php-parser-34bea19b6e03d8153165d8f30bba4c3be86184c1";
        src = fetchurl {
          url = "https://api.github.com/repos/nikic/PHP-Parser/zipball/34bea19b6e03d8153165d8f30bba4c3be86184c1";
          sha256 = "1yj97j9cdx48566qwjl5q8hkjkrd1xl59aczb1scspxay37l9w72";
        };
      };
    };
    "openlss/lib-array2xml" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "openlss-lib-array2xml-a91f18a8dfc69ffabe5f9b068bc39bb202c81d90";
        src = fetchurl {
          url = "https://api.github.com/repos/nullivex/lib-array2xml/zipball/a91f18a8dfc69ffabe5f9b068bc39bb202c81d90";
          sha256 = "0h8f4ag6gq7xbh6bvybzbfmnxcsyqnk9dni0bdm195bnjqjw1l2q";
        };
      };
    };
    "phar-io/manifest" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phar-io-manifest-97803eca37d319dfa7826cc2437fc020857acb53";
        src = fetchurl {
          url = "https://api.github.com/repos/phar-io/manifest/zipball/97803eca37d319dfa7826cc2437fc020857acb53";
          sha256 = "107dsj04ckswywc84dvw42kdrqd4y6yvb2qwacigyrn05p075c1w";
        };
      };
    };
    "phar-io/version" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phar-io-version-4f7fd7836c6f332bb2933569e566a0d6c4cbed74";
        src = fetchurl {
          url = "https://api.github.com/repos/phar-io/version/zipball/4f7fd7836c6f332bb2933569e566a0d6c4cbed74";
          sha256 = "0mdbzh1y0m2vvpf54vw7ckcbcf1yfhivwxgc9j9rbb7yifmlyvsg";
        };
      };
    };
    "php-cs-fixer/diff" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "php-cs-fixer-diff-29dc0d507e838c4580d018bd8b5cb412474f7ec3";
        src = fetchurl {
          url = "https://api.github.com/repos/PHP-CS-Fixer/diff/zipball/29dc0d507e838c4580d018bd8b5cb412474f7ec3";
          sha256 = "12b0ga9i0racym4vvql26kjjiqx2940j0345kmy9zjbamm6jzlzl";
        };
      };
    };
    "phpactor/test-utils" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpactor-test-utils-1a2531b54a56f71fab270100d90d9ec6e27bff62";
        src = fetchurl {
          url = "https://api.github.com/repos/phpactor/test-utils/zipball/1a2531b54a56f71fab270100d90d9ec6e27bff62";
          sha256 = "1q4sqkipv8h5g0076ds12fb2lqiih2w44my2pnxll6amnvchpsw3";
        };
      };
    };
    "phpbench/container" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpbench-container-6d555ff7174fca13f9b1ec0b4a089ed41d0ab392";
        src = fetchurl {
          url = "https://api.github.com/repos/phpbench/container/zipball/6d555ff7174fca13f9b1ec0b4a089ed41d0ab392";
          sha256 = "02j7b5ss72937iin0rsa6h42kp8k3p3hl6x7526qnv9j8xq02nmp";
        };
      };
    };
    "phpbench/dom" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpbench-dom-b013b717832ddbaadf2a40984b04bc66af9a7110";
        src = fetchurl {
          url = "https://api.github.com/repos/phpbench/dom/zipball/b013b717832ddbaadf2a40984b04bc66af9a7110";
          sha256 = "1rjqqiz78drz6c589c4fpypi22xj71fn29xhz1xf8ik7rzgnifzx";
        };
      };
    };
    "phpbench/phpbench" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpbench-phpbench-c30fac992e72b505a1f131790583647f4d3255c3";
        src = fetchurl {
          url = "https://api.github.com/repos/phpbench/phpbench/zipball/c30fac992e72b505a1f131790583647f4d3255c3";
          sha256 = "0w5ljpzjylc953j4h2p30hypgb1i0kbnkg4fwrrm8mg3c0j4yd2v";
        };
      };
    };
    "phpdocumentor/reflection-common" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpdocumentor-reflection-common-1d01c49d4ed62f25aa84a747ad35d5a16924662b";
        src = fetchurl {
          url = "https://api.github.com/repos/phpDocumentor/ReflectionCommon/zipball/1d01c49d4ed62f25aa84a747ad35d5a16924662b";
          sha256 = "1wx720a17i24471jf8z499dnkijzb4b8xra11kvw9g9hhzfadz1r";
        };
      };
    };
    "phpdocumentor/reflection-docblock" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpdocumentor-reflection-docblock-622548b623e81ca6d78b721c5e029f4ce664f170";
        src = fetchurl {
          url = "https://api.github.com/repos/phpDocumentor/ReflectionDocBlock/zipball/622548b623e81ca6d78b721c5e029f4ce664f170";
          sha256 = "1vs0fhpqk8s9bc0sqyfhpbs63q14lfjg1f0c1dw4jz97145j6r1n";
        };
      };
    };
    "phpdocumentor/type-resolver" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpdocumentor-type-resolver-77a32518733312af16a44300404e945338981de3";
        src = fetchurl {
          url = "https://api.github.com/repos/phpDocumentor/TypeResolver/zipball/77a32518733312af16a44300404e945338981de3";
          sha256 = "0y6byv5psmrcy6ga7nghzblv61rjbni046h0pgjda8r8qmz26yr4";
        };
      };
    };
    "phpspec/prophecy" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpspec-prophecy-bbcd7380b0ebf3961ee21409db7b38bc31d69a13";
        src = fetchurl {
          url = "https://api.github.com/repos/phpspec/prophecy/zipball/bbcd7380b0ebf3961ee21409db7b38bc31d69a13";
          sha256 = "1xw7x12lws8qdrryhbgjiih48gxwlq99ayhhsy0q2ls9i9p6mw0w";
        };
      };
    };
    "phpspec/prophecy-phpunit" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpspec-prophecy-phpunit-2d7a9df55f257d2cba9b1d0c0963a54960657177";
        src = fetchurl {
          url = "https://api.github.com/repos/phpspec/prophecy-phpunit/zipball/2d7a9df55f257d2cba9b1d0c0963a54960657177";
          sha256 = "07dxv6bp7iz0qbhyk0irw3vsq2ikm4h3c6czqa5a31n8kqh1cini";
        };
      };
    };
    "phpstan/extension-installer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpstan-extension-installer-66c7adc9dfa38b6b5838a9fb728b68a7d8348051";
        src = fetchurl {
          url = "https://api.github.com/repos/phpstan/extension-installer/zipball/66c7adc9dfa38b6b5838a9fb728b68a7d8348051";
          sha256 = "12i8arlgw11n3x622kdbmx935agjm93gj6lw92illwlvwr37jrgs";
        };
      };
    };
    "phpstan/phpstan" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpstan-phpstan-c53312ecc575caf07b0e90dee43883fdf90ca67c";
        src = fetchurl {
          url = "https://api.github.com/repos/phpstan/phpstan/zipball/c53312ecc575caf07b0e90dee43883fdf90ca67c";
          sha256 = "1g2zqzx8jr63p489gzgz4c4lnp916i56y1w30vpknlhn7gliqw6l";
        };
      };
    };
    "phpstan/phpstan-phpunit" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpstan-phpstan-phpunit-4a3c437c09075736285d1cabb5c75bf27ed0bc84";
        src = fetchurl {
          url = "https://api.github.com/repos/phpstan/phpstan-phpunit/zipball/4a3c437c09075736285d1cabb5c75bf27ed0bc84";
          sha256 = "1vwnzxn9qr8n1nmrpf8hb6220plpr340nbkm11p5i7dik7b93ara";
        };
      };
    };
    "phpunit/php-code-coverage" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-code-coverage-2e9da11878c4202f97915c1cb4bb1ca318a63f5f";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-code-coverage/zipball/2e9da11878c4202f97915c1cb4bb1ca318a63f5f";
          sha256 = "1dnslzhpj6hzsb6dzxd722sg2kk51mm0l5lwyrkng857ph82dgsj";
        };
      };
    };
    "phpunit/php-file-iterator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-file-iterator-cf1c2e7c203ac650e352f4cc675a7021e7d1b3cf";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-file-iterator/zipball/cf1c2e7c203ac650e352f4cc675a7021e7d1b3cf";
          sha256 = "1407d8f1h35w4sdikq2n6cz726css2xjvlyr1m4l9a53544zxcnr";
        };
      };
    };
    "phpunit/php-invoker" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-invoker-5a10147d0aaf65b58940a0b72f71c9ac0423cc67";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-invoker/zipball/5a10147d0aaf65b58940a0b72f71c9ac0423cc67";
          sha256 = "1vqnnjnw94mzm30n9n5p2bfgd3wd5jah92q6cj3gz1nf0qigr4fh";
        };
      };
    };
    "phpunit/php-text-template" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-text-template-5da5f67fc95621df9ff4c4e5a84d6a8a2acf7c28";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-text-template/zipball/5da5f67fc95621df9ff4c4e5a84d6a8a2acf7c28";
          sha256 = "0ff87yzywizi6j2ps3w0nalpx16mfyw3imzn6gj9jjsfwc2bb8lq";
        };
      };
    };
    "phpunit/php-timer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-timer-5a63ce20ed1b5bf577850e2c4e87f4aa902afbd2";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-timer/zipball/5a63ce20ed1b5bf577850e2c4e87f4aa902afbd2";
          sha256 = "0g1g7yy4zk1bidyh165fsbqx5y8f1c8pxikvcahzlfsr9p2qxk6a";
        };
      };
    };
    "phpunit/phpunit" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-phpunit-0e32b76be457de00e83213528f6bb37e2a38fcb1";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/phpunit/zipball/0e32b76be457de00e83213528f6bb37e2a38fcb1";
          sha256 = "0kixvly1xkwlv2sl68zld1rs3q94mvb7d13d1650y1jszzbd6iq4";
        };
      };
    };
    "psr/cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-cache-d11b50ad223250cf17b86e38383413f5a6764bf8";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/cache/zipball/d11b50ad223250cf17b86e38383413f5a6764bf8";
          sha256 = "06i2k3dx3b4lgn9a4v1dlgv8l9wcl4kl7vzhh63lbji0q96hv8qz";
        };
      };
    };
    "sebastian/cli-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-cli-parser-442e7c7e687e42adc03470c7b668bc4b2402c0b2";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/cli-parser/zipball/442e7c7e687e42adc03470c7b668bc4b2402c0b2";
          sha256 = "074qzdq19k9x4svhq3nak5h348xska56v1sqnhk1aj0jnrx02h37";
        };
      };
    };
    "sebastian/code-unit" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-code-unit-1fc9f64c0927627ef78ba436c9b17d967e68e120";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/code-unit/zipball/1fc9f64c0927627ef78ba436c9b17d967e68e120";
          sha256 = "04vlx050rrd54mxal7d93pz4119pas17w3gg5h532anfxjw8j7pm";
        };
      };
    };
    "sebastian/code-unit-reverse-lookup" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-code-unit-reverse-lookup-ac91f01ccec49fb77bdc6fd1e548bc70f7faa3e5";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/code-unit-reverse-lookup/zipball/ac91f01ccec49fb77bdc6fd1e548bc70f7faa3e5";
          sha256 = "1h1jbzz3zak19qi4mab2yd0ddblpz7p000jfyxfwd2ds0gmrnsja";
        };
      };
    };
    "sebastian/comparator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-comparator-55f4261989e546dc112258c7a75935a81a7ce382";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/comparator/zipball/55f4261989e546dc112258c7a75935a81a7ce382";
          sha256 = "1d4bgf4m2x0kn3nw9hbb45asbx22lsp9vxl74rp1yl3sj2vk9sch";
        };
      };
    };
    "sebastian/complexity" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-complexity-739b35e53379900cc9ac327b2147867b8b6efd88";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/complexity/zipball/739b35e53379900cc9ac327b2147867b8b6efd88";
          sha256 = "1y4yz8n8hszbhinf9ipx3pqyvgm7gz0krgyn19z0097yq3bbq8yf";
        };
      };
    };
    "sebastian/environment" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-environment-1b5dff7bb151a4db11d49d90e5408e4e938270f7";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/environment/zipball/1b5dff7bb151a4db11d49d90e5408e4e938270f7";
          sha256 = "0qhpamp9hi00zh7warf3mfbfrrpj1rdci90nnzibvii0vdp98691";
        };
      };
    };
    "sebastian/exporter" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-exporter-65e8b7db476c5dd267e65eea9cab77584d3cfff9";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/exporter/zipball/65e8b7db476c5dd267e65eea9cab77584d3cfff9";
          sha256 = "071813jw7nlsa3fs1hlrkl5fsjz4sidyq0i26p22m43isvvyad0q";
        };
      };
    };
    "sebastian/global-state" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-global-state-0ca8db5a5fc9c8646244e629625ac486fa286bf2";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/global-state/zipball/0ca8db5a5fc9c8646244e629625ac486fa286bf2";
          sha256 = "1csrfa5b7ivza712lfmbywp9jhwf4ls5lc0vn812xljkj7w24kg1";
        };
      };
    };
    "sebastian/lines-of-code" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-lines-of-code-c1c2e997aa3146983ed888ad08b15470a2e22ecc";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/lines-of-code/zipball/c1c2e997aa3146983ed888ad08b15470a2e22ecc";
          sha256 = "0fay9s5cm16gbwr7qjihwrzxn7sikiwba0gvda16xng903argbk0";
        };
      };
    };
    "sebastian/object-enumerator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-object-enumerator-5c9eeac41b290a3712d88851518825ad78f45c71";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/object-enumerator/zipball/5c9eeac41b290a3712d88851518825ad78f45c71";
          sha256 = "11853z07w8h1a67wsjy3a6ir5x7khgx6iw5bmrkhjkiyvandqcn1";
        };
      };
    };
    "sebastian/object-reflector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-object-reflector-b4f479ebdbf63ac605d183ece17d8d7fe49c15c7";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/object-reflector/zipball/b4f479ebdbf63ac605d183ece17d8d7fe49c15c7";
          sha256 = "0g5m1fswy6wlf300x1vcipjdljmd3vh05hjqhqfc91byrjbk4rsg";
        };
      };
    };
    "sebastian/recursion-context" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-recursion-context-cd9d8cf3c5804de4341c283ed787f099f5506172";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/recursion-context/zipball/cd9d8cf3c5804de4341c283ed787f099f5506172";
          sha256 = "1k0ki1krwq6329vsbw3515wsyg8a7n2l83lk19pdc12i2lg9nhpy";
        };
      };
    };
    "sebastian/resource-operations" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-resource-operations-0f4443cb3a1d92ce809899753bc0d5d5a8dd19a8";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/resource-operations/zipball/0f4443cb3a1d92ce809899753bc0d5d5a8dd19a8";
          sha256 = "0p5s8rp7mrhw20yz5wx1i4k8ywf0h0ximcqan39n9qnma1dlnbyr";
        };
      };
    };
    "sebastian/type" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-type-b233b84bc4465aff7b57cf1c4bc75c86d00d6dad";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/type/zipball/b233b84bc4465aff7b57cf1c4bc75c86d00d6dad";
          sha256 = "057a4yk5rhgnq99l024gx8b1gxliyyf7q1x6w37nwzckq3a419yv";
        };
      };
    };
    "sebastian/version" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-version-c6c1022351a901512170118436c764e473f6de8c";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/version/zipball/c6c1022351a901512170118436c764e473f6de8c";
          sha256 = "1bs7bwa9m0fin1zdk7vqy5lxzlfa9la90lkl27sn0wr00m745ig1";
        };
      };
    };
    "seld/jsonlint" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "seld-jsonlint-4211420d25eba80712bff236a98960ef68b866b7";
        src = fetchurl {
          url = "https://api.github.com/repos/Seldaek/jsonlint/zipball/4211420d25eba80712bff236a98960ef68b866b7";
          sha256 = "1sgfwxipspih3xhzivpdykcfnbk9ydhzpi8vc8q0jxsd4q8kf38c";
        };
      };
    };
    "symfony/event-dispatcher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-event-dispatcher-8e6ce1cc0279e3ff3c8ff0f43813bc88d21ca1bc";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/event-dispatcher/zipball/8e6ce1cc0279e3ff3c8ff0f43813bc88d21ca1bc";
          sha256 = "10vdzpy7gvmy0w4lpr4h4xj2gr224k5llc7f356x1jzbijxg8ckh";
        };
      };
    };
    "symfony/event-dispatcher-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-event-dispatcher-contracts-f98b54df6ad059855739db6fcbc2d36995283fe1";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/event-dispatcher-contracts/zipball/f98b54df6ad059855739db6fcbc2d36995283fe1";
          sha256 = "114zpsd8vac016a0ppf5ag5lmgllrha7nwln8vvhq9282r79xhsl";
        };
      };
    };
    "symfony/finder" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-finder-9b630f3427f3ebe7cd346c277a1408b00249dad9";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/finder/zipball/9b630f3427f3ebe7cd346c277a1408b00249dad9";
          sha256 = "0b2rdx4080jav1ixqxrl4mabn91amf81xsj533b067vdfq4rcfv4";
        };
      };
    };
    "symfony/options-resolver" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-options-resolver-cc1147cb11af1b43f503ac18f31aa3bec213aba8";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/options-resolver/zipball/cc1147cb11af1b43f503ac18f31aa3bec213aba8";
          sha256 = "0jnn1aybjfah3ivhgrc5k6bwhs5r90f0fdcybhp95an0wxr6z45z";
        };
      };
    };
    "symfony/stopwatch" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-stopwatch-4d04b5c24f3c9a1a168a131f6cbe297155bc0d30";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/stopwatch/zipball/4d04b5c24f3c9a1a168a131f6cbe297155bc0d30";
          sha256 = "1a74m90mmix2296q9za76s3pfpiakfw03sjx78nga0f312zmqzai";
        };
      };
    };
    "symfony/var-dumper" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-var-dumper-af52239a330fafd192c773795520dc2dd62b5657";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/var-dumper/zipball/af52239a330fafd192c773795520dc2dd62b5657";
          sha256 = "1dxmwyg3wxq313zfrjwywkfsi38lq6i3prq69f47vbiqajfs55jn";
        };
      };
    };
    "theseer/tokenizer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "theseer-tokenizer-34a41e998c2183e22995f158c581e7b5e755ab9e";
        src = fetchurl {
          url = "https://api.github.com/repos/theseer/tokenizer/zipball/34a41e998c2183e22995f158c581e7b5e755ab9e";
          sha256 = "1za4a017kjb4rw2ydglip4bp5q2y7mfiycj3fvnp145i84jc7n0q";
        };
      };
    };
    "vimeo/psalm" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "vimeo-psalm-06dd975cb55d36af80f242561738f16c5f58264f";
        src = fetchurl {
          url = "https://api.github.com/repos/vimeo/psalm/zipball/06dd975cb55d36af80f242561738f16c5f58264f";
          sha256 = "1d1r71p0n3lcn0d79wjs1n0misdj15wkfdgqkb5ag9vf6p10fkz2";
        };
      };
    };
  };
}
