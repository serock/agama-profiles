local agama = import "hw.libsonnet";
local board = agama.findByID(agama.lshw, "core").product;
local getHostname() =
  if board == "PRIME H370M-PLUS" then
    "desktop"
  else if board == "4239CTO" then
    "laptop15"
  else if board == "IPXBD-RB" then
    "mini"
  else if board == "VirtualBox" then
    "vbox"
  else
    "agama";

{
  product: {
    // Clue: https://github.com/agama-project/agama/blob/c794bbb9adc612709baf76c1c6e67f9cc3c0e4f9/products.d/leap_160.yaml#L1
    id: "Leap_16.0"
  },
  localization: {
    language: "en_US.UTF-8",
    keyboard: "us",
    timezone: "America/New_York"
  },
  // Clue: https://agama-project.github.io/docs/user/reference/profile/users#first-user
  user: {
    fullName: "John",
    userName: "john",
    hashedPassword: true,
    // Clue: https://agama-project.github.io/docs/user/reference/profile/users#encrypted-passwords
    password: "$6$5SFO1XN8VAyuwW.G$LaLNJCAAuqCyT.dgEUW9r4VtDSuS4mRvxnWnMaJC4Wc9THz.Uc/SQDxXuY9Kc8zpAJ1G4FKTWou9t/qEZPSAM1"
  },
  root: {
    hashedPassword: $.user.hashedPassword,
    password: $.user.password
  },
  hostname: {
    static: getHostname()
  },
  scripts: {
    post: [
      {
        chroot: true,
        name: "cdn-disable-non-oss",
        content: |||
          #!/bin/bash
          zypper refresh --services
          zypper modifyrepo --disable openSUSE:repo-non-oss
        |||
      },
      {
        chroot: true,
        name: "chrony-dhcp",
        content: |||
          #!/bin/bash
          cp /usr/share/doc/packages/chrony/examples/chrony.nm-dispatcher.dhcp /etc/NetworkManager/dispatcher.d/20-chrony-dhcp
          chmod 755 /etc/NetworkManager/dispatcher.d/20-chrony-dhcp
        |||
      },
      {
        chroot: true,
        name: "software-remove",
        content: |||
          #!/bin/bash
          zypper --non-interactive remove chrony-pool-openSUSE
          zypper --non-interactive addlock chrony-pool-openSUSE
          zypper --non-interactive remove opensuse-welcome
          zypper --non-interactive addlock opensuse-welcome
          zypper --non-interactive remove opensuse-welcome-launcher
          zypper --non-interactive addlock opensuse-welcome-launcher
        |||
      },
      {
        chroot: true,
        name: "software-install",
        content: |||
          #!/bin/bash
          zypper --non-interactive install chrony-pool-empty
          zypper --non-interactive install mozilla-openh264
        |||
      },
      {
        chroot: true,
        name: "groups-append",
        content: |||
          #!/bin/bash
          getent group docker    && usermod --append --groups docker %(user)s
          getent group osc       && usermod --append --groups osc %(user)s
          getent group vboxsf    && usermod --append --groups vboxsf %(user)s
          getent group vboxusers && usermod --append --groups vboxusers %(user)s
          getent group wireshark && usermod --append --groups wireshark %(user)s
          exit 0
        ||| % {user: $.user.userName}
      }
    ],
    init: [
      {
        name: "mm-disable",
        content: |||
          #!/bin/bash
          systemctl disable ModemManager.service
        |||
      },
      {
        name: "nm-init",
        url: "https://github.com/serock/agama-profiles/raw/main/network-manager.sh"
      },
      {
        name: "vbox-guest-additions-iso",
        // Clue: https://www.virtualbox.org/manual/topics/guestadditions.html#ariaid-title5
        content: |||
          #!/bin/bash
          version=$(VBoxManage --version) || exit 1
          version=${version%_SUSEr+([0-9])}
          curl --cert-status --compressed --create-dirs --no-progress-meter --output-dir /usr/lib/virtualbox/additions --remote-name https://download.virtualbox.org/virtualbox/${version}/VBoxGuestAdditions_${version}.iso
          ln --relative --symbolic /usr/lib/virtualbox/additions/VBoxGuestAdditions_${version}.iso /usr/lib/virtualbox/additions/VBoxGuestAdditions.iso
        |||
      }
    ]
  },
  storage: {
    boot: {
      configure: true,
      device: "bootdrive"
    },
    drives: [
      {
        // Clue: https://agama-project.github.io/blog/2025/07/04/agama-16#search
        search: {
          "sort": {
            "size": "desc"
          },
          "max": 1
        },
        alias: "bootdrive",
        ptableType: "gpt",
        partitions: [
          {
            search: "*",
            delete: true
          },
          {
            filesystem: {
              type: "ext4",
              path: "/",
              mountBy: "uuid",
              mountOptions: [
                "defaults",
                "noatime"
              ]
            },
            size: "16 GiB"
          },
          {
            encryption: {
              luks2: {
                password: "changeme",
                pbkdFunction: "pbkdf2"
              }
            },
            filesystem: {
              type: "ext4",
              path: "/home",
              mountBy: "uuid",
              mountOptions: [
                "defaults",
                "noatime"
              ]
            }
          },
          {
            encryption: "random_swap",
            filesystem: {
              type: "swap",
              path: "swap"
            },
            size: "2 GiB"
          }
        ]
      }
    ]
  },
  software: {
    patterns: {
      add: [
        "gnome",
        "cockpit"
      ]
    },
    packages: [
      "avahi-utils",
      "bijiben",
      "chromium",
      "efitools",
      "efivar",
      "git-core",
      "hplip",
      "imagewriter",// missing
      "keepassxc",
      "libcap-ng-utils",
      "libpcap-devel",
      "lshw",
      "myrlyn",
      "python313-Pillow-tk",
      "sbctl",
      "sbsigntools",
      "wireshark-ui-qt",
      "yubikey-manager",
      "yubioath-flutter"// missing
    ] + (
      if board == "PRIME H370M-PLUS" then [
        "apcupsd-gui",// missing
        "bash-completion-devel",
        "bash-completion-doc",
        "binwalk",
        "checksec",
        "devscripts",
        "docker-bash-completion",
        "dpkg",
        "gcc-ada",
        "gcc-c++",
        "git-gui",
        "gitk",
        "gnucash",
        "homebank",
        "java-21-openjdk-devel",
        "maven",
        "mkvtoolnix",
        "nvme-cli-bash-completion",
        "osc",
        "pavucontrol",
        "quilt",
        "rpm-devel",
        "rpmdevtools",
        "rpmlint",
        "rpmlint-mini",
        "rpmlint-strict",
        "virtualbox-qt"// missing
      ] else if board == "VirtualBox" then [
        "virtualbox-guest-tools"// missing
      ] else []
    )
  },
  questions: {
    answers: [
      {
        // Clue: https://agama-project.github.io/docs/user/reference/profile/answers#supported-question-classes
        class: "storage.luks_activation",
        answer: "skip"
      }
    ]
  },
  files: [
    {
      // Clue: https://www.chromium.org/administrators/linux-quick-start/#set-up-policies
      // Clue: https://chromium.googlesource.com/chromium/src/+/HEAD/docs/enterprise/policies.md#policy-sources
      // Clue: chrome://policy/logs
      destination: "/etc/chromium/policies/managed/chromium-policies.json",
      url: "https://github.com/serock/agama-profiles/raw/main/chromium-policies.json",
      permissions: "644",
      user: "root",
      group: "root"
    },
    {
      // Clue: https://mozilla.github.io/policy-templates/
      destination: "/etc/firefox/policies/policies.json",
      url: "https://github.com/serock/agama-profiles/raw/main/firefox-policies.json",
      permissions: "644",
      user: "root",
      group: "root"
    },
    {
      destination: "/etc/security/limits.conf",
      content: |||
        # man limits.conf
        #
        *               soft    core            0
      |||,
      permissions: "644",
      user: "root",
      group: "root"
    }
  ] + (
    if board == "PRIME H370M-PLUS" then [
      {
        destination: "/etc/apcupsd/apcupsd.conf",
        url: "https://github.com/serock/agama-profiles/raw/main/apcupsd.conf",
        permissions: "644",
        user: "root",
        group: "root"
      },
      {
        // Clue: https://openbuildservice.org/help/manuals/obs-user-guide/art-obs-bg#pro-obsbg-obsconfig
        destination: "/etc/sudoers.d/osc",
        content: |||
          # sudoers file "/etc/sudoers.d/osc" for the osc group
          Cmnd_Alias  OSC_CMD = /usr/bin/osc, /usr/bin/build
          %osc  ALL = (ALL) NOPASSWD:OSC_CMD
        |||,
        // Clue: visudo --check
        permissions: "440",
        user: "root",
        group: "root"
      }
    ] else []
  )
}
