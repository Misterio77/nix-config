{ config, pkgs, lib, ... }:

let inherit (config.colorscheme) colors;
in {
  home.packages = with pkgs; [ discord discocss ];

  home.persistence = {
    "/persist/home/misterio".directories = [ ".config/discord" ];
  };

  xdg.configFile."discocss/custom.css".text = ''
    .theme-dark {
        --header-primary: #${colors.base05};
        --header-secondary: #${colors.base04};
        --text-normal: #${colors.base05};
        --text-muted: #${colors.base04};
        --text-link: #${colors.base08};
        --channels-default: #${colors.base05};
        --interactive-normal: #${colors.base04};
        --interactive-hover: #${colors.base05};
        --interactive-active: #${colors.base05};
        --interactive-muted: #${colors.base03};
        --background-primary: #${colors.base00};
        --background-secondary: #${colors.base01};
        --background-secondary-alt: #${colors.base02};
        --background-tertiary: #${colors.base01};
        --background-accent: #${colors.base01};
        --background-floating: #${colors.base00};
        --background-mobile-primary: var(--background-primary);
        --background-mobile-secondary: var(--background-secondary);
        --background-modifier-selected: var(--background-secondary);
        --scrollbar-thin-thumb: #${colors.base02};
        --scrollbar-auto-thumb: #${colors.base02};
        --scrollbar-auto-track: #${colors.base01};
        --scrollbar-auto-scrollbar-color-thumb: #${colors.base02};
        --scrollbar-auto-scrollbar-color-track: #${colors.base01};
        --focus-primary: #${colors.base08};
        --channeltextarea-background: #${colors.base01};
        --deprecated-card-bg: #${colors.base01};
        --deprecated-quickswitcher-input-background: #${colors.base01};
        --deprecated-quickswitcher-input-placeholder: #${colors.base05};
        --background-modifier-hover: var(--background-secondary);
        --background-modifier-active: var(--background-secondary-alt);
        --activity-card-background: var(--background-secondary);
    }
    body {
        font-family: ${config.fontProfiles.regular.family}, sans serif;
    }
    .scroller-1Bvpku {
        background-color: var(--background-primary);
    }
    .scroller-2FKFPG {
        background-color: var(--background-primary);
    }
    .headerPlaying-j0WQBV, .headerStreaming-2FjmGz {
        background: var(--background-secondary-alt);
    }
    .theme-dark .headerNormal-T_seeN {
        background-color: var(--background-primary);
    }
    .theme-dark .body-3iLsc4, .theme-dark .footer-1fjuF6 {
        background-color: var(--background-primary);
        color: var(--header-secondary);
    }
    .theme-dark .quickMessage-1yeL4E {
        background-color: var(--background-secondary);
        border-color: var(--background-secondary);
    }
    .theme-dark .inset-3sAvek {
        background-color: var(--background-secondary);
    }
    .theme-dark .userSettingsAccount-2eMFVR .viewBody-2Qz-jg {
        color: var(--header-primary);
    }
    .theme-dark .modal-yWgWj- {
        background-color: var(--background-primary);
    }
    .theme-dark .footer-2gL1pp {
        background-color: var(--background-primary);
    }
    .theme-dark .lookLink-9FtZy-.colorPrimary-3b3xI6 {
        color: var(--header-primary);
    }
    .theme-dark .notDetected-33MY4s, .theme-light .notDetected-33MY4s {
        background-color: var(--background-primary);
    }
    .theme-dark .notDetected-33MY4s .gameName-1RiWHm, .theme-light .notDetected-33MY4s .gameName-1RiWHm {
        color: var(--header-primary);
    }
    .theme-dark .gameName-1RiWHm {
        color: var(--header-primary);
    }
    .theme-dark .notDetected-33MY4s .lastPlayed-3bQ7Bo, .theme-light .notDetected-33MY4s .lastPlayed-3bQ7Bo {
        color: var(--header-primary);
    }
    .theme-dark .nowPlayingAdd-1Kdmh_, .theme-light .nowPlayingAdd-1Kdmh_ {
        color: var(--header-primary);
    }
    .css-1k00wn6-singleValue {
        color: var(--header-primary);
    }
    .theme-dark .codeRedemptionRedirect-1wVR4b {
        color: var(--header-primary);
        background-color: var(--background-primary);
        border-color: var(--background-primary);
    }
    .theme-dark .emptyStateHeader-248f_b {
        color: var(--header-primary);
    }
    .theme-dark .emptyStateSubtext-2hdA9c {
        color: var(--header-primary);
    }
    .theme-dark .root-1gCeng {
        background-color: var(--background-primary);
    }
    .theme-dark .date-EErlv4 {
        color: var(--header-primary);
    }
    .theme-dark .content-8bidB ol, .theme-dark .content-8biNdB p, .theme-dark .content-8biNdB ul li {
        color: var(--header-primary);
    }
    .headerName-fajvi9, .headerTagUsernameNoNickname-2_H881 {
        color: var(--header-primary);
    }
    .headerTag-2pZJzA {
        color: var(--header-secondary);
    }
    .theme-dark .activityProfile-2bJRaP .headerText-1HLrL7, .theme-dark .activityUserPopout-2yItg2 .headerText-1HLrL7, .theme-light .activityProfile-2bJRaP .headerText-1HLrL7, .theme-light .activityUserPopout-2yItg2 .headerText-1HLrL7 {
        color: var(--header-secondary);
    }
    .activityName-1IaRLn, .nameNormal-2lqVQK, .nameWrap-3Z4G_9 {
        color: var(--header-secondary);
    }
    .theme-dark .activityProfile-2bJRaP .content-3JfFJh, .theme-dark .activityProfile-2bJRaP .details-38sfDr, .theme-dark .activityProfile-2bJRaP .name-29ETJS, .theme-dark .activityUserPopout-2yItg2 .content-3JfFJh, .theme-dark .activityUserPopout-2yItg2 .details-38sfDr, .theme-dark .activityUserPopout-2yItg2 .name-29ETJS, .theme-light .activityProfile-2bJRaP .content-3JfFJh, .theme-light .activityProfile-2bJRaP .details-38sfDr, .theme-light .activityProfile-2bJRaP .name-29ETJS, .theme-light .activityUserPopout-2yItg2 .content-3JfFJh, .theme-light .activityUserPopout-2yItg2 .details-38sfDr, .theme-light .activityUserPopout-2yItg2 .name-29ETJS {
        color: var(--header-secondary);
    }
    .topSectionPlaying-1J5E4n {
        background: var(--background-secondary-alt);
    }
    .username-3gJmXY {
        color: var(--header-primary);
    }
    .discriminator-xUhQkU {
        color: var(--header-secondary);
    }
    .tabBarItem-1b8RUP.item-PXvHYJ {
        color: var(--header-secondary) !important;
        border-color: transparent !important;
    }
    .theme-dark .keybind-KpFkfr {
        color: var(--header-primary);
    }
    .theme-dark .closeButton-1tv5uR {
        border-color: var(--header-primary);
    }
    .barFill-23-gu- {
        background: var(--text-link);
    }
    .focused-3afm-j {
        background-color: var(--background-secondary) !important;
        color: var(--text-link) !important;
    }
    .colorDefault-2K3EoJ .checkbox-3s5GYZ, .colorDefault-2K3EoJ .radioSelection-1HmrQS {
        color: var(--text-link);
    }
    .colorDefault-2K3EoJ .checkbox-3s5GYZ {
        color: var(--text-link);
    }
    .colorDefault-2K3EoJ .check-1JyqgN {
        color: var(--background-primary);
    }
    .colorDefault-2K3EoJ.focused-3afm-j .checkbox-3s5GYZ {
        color: var(--background-primary) !important;
    }
    .colorDefault-2K3EoJ.focused-3afm-j .check-1JyqgN {
        color: var(--text-link);
    }
    .wrapper-1BJsBx.selected-bZ3Lue .childWrapper-anI2G9, .wrapper-1BJsBx:hover .childWrapper-anI2G9 {
        color: var(--background-primary);
        background-color: var(--header-secondary);
    }
    .panels-j1Uci_ {
        background-color: var(--background-primary);
    }
    .navButton-2gQCx- {
        color: var(--interactive-normal);
    }
    .navButtonActive-1MkytQ {
        color: var(--header-primary);
    }
    .input-3Xdcic {
        color: var(--header-primary);
    }
    .clickable-2ap7je .header-2o-2hj {
        background-color: var(--background-primary);
    }
    .peopleColumn-29fq28 {
        background-color: var(--background-tertiary);
    }
    .theme-dark .outer-1AjyKL.active-1xchHY, .theme-dark .outer-1AjyKL.interactive-3B9GmY:hover {
        background-color: var(--background-primary);
    }

    .theme-dark .popout-38lTFE {
        background-color: var(--background-primary);
    }

    .theme-dark .scrollerThemed-2oenus.themedWithTrack-q8E3vB>.scroller-2FKFPG::-webkit-scrollbar-track-piece {
        background-color: var(--background-primary);
        border: 4px solid var(--background-secondary);
    }

    .theme-dark .scrollerThemed-2oenus.themedWithTrack-q8E3vB>.scroller-2FKFPG::-webkit-scrollbar-thumb {
        background-color: var(--background-secondary);
        border-color: var(--background-secondary);
    }
    .theme-dark .header-sJd8D7 {
      color: var(--text-normal)
    }
  '';
}
