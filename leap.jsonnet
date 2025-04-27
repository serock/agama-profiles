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
local drive = std.sort(
  std.filter(
    function(d) std.objectHas(d, "size"),
    agama.selectByClass(agama.lshw, "disk")),
  function(x) -x.size)[0].logicalname;

{
  product: {
    id: "Leap_16.0"
  },
  localization: {
    language: "en_US.UTF-8",
    keyboard: "us",
    timezone: "America/New_York"
  },
  user: {
    fullName: "John",
    userName: "john",
    hashedPassword: true,
    password: "$6$5SFO1XN8VAyuwW.G$LaLNJCAAuqCyT.dgEUW9r4VtDSuS4mRvxnWnMaJC4Wc9THz.Uc/SQDxXuY9Kc8zpAJ1G4FKTWou9t/qEZPSAM1"
  },
  root: {
    hashedPassword: $.user.hashedPassword,
    password: $.user.password
  },
  hostname: {
    static: getHostname()
  },
  network: {
    connections: [
      {
        id: "wired-home",
        method4: "auto",
        method6: "disabled",
        match: {
          driver: ["e1000e", "e1000"]
        }
      }
    ]
  },
  scripts: {
    post: [
      {
        chroot: true,
        name: "cdn",
        url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/cdn.sh"
      },
      {
        chroot: true,
        name: "chrony-dhcp",
        url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/chrony-dhcp.sh"
      },
      {
        chroot: true,
        name: "chrony-pool",
        url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/chrony-pool.sh"
      },
      {
        name: "nm",
        url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/network-manager.sh"
      },
      {
        chroot: true,
        name: "welcome",
        url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/welcome.sh"
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
        search: drive,
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
            size: "10 GiB"
          },
          {
            encryption: {
              luks2: {
                password: "nots3cr3t",
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
    patterns: [
      "gnome"
    ],
    packages: [
      "avahi-utils",
      "bijiben",
      "chromium",
      "ddclient",
      "git-core",
      "gstreamer-plugin-openh264",
      "hplip-scan-utils",
      "imagewriter",
      "keepassxc",
      "libcap-ng-utils",
      "libfido2-udev",
      "libpcap-devel",
      "lshw",
      "mozilla-openh264",
      "python313-Pillow-tk",
      "simple-scan",
      "wireshark-ui-qt",
      "yubikey-manager-qt",
      "yubioath-desktop"
    ] + (
      if board == "PRIME H370M-PLUS" then [
        "apcupsd-gui",
        "bash-completion-devel",
        "bash-completion-doc",
        "binwalk",
        "checksec",
        "devscripts",
        "docker-bash-completion",
        "dpkg",
        "gcc-PIE",
        "gcc-ada",
        "gcc-c++",
        "gcc14-PIE",
        "gcc14-ada",
        "gcc14-c++",
        "git-gui",
        "gitk",
        "gnucash",
        "homebank",
        "java-21-openjdk-devel",
        "lighttpd",
        "maven",
        "mkvtoolnix",
        "nvme-cli-bash-completion",
        "osc",
        "pavucontrol",
        "quilt",
        "rpm-devel",
        "rpmdevtools",
        "rpmlint",
        "rpmlint-Factory",
        "virtualbox-qt"
      ] else []
    )
  },
  files: [
    {
      destination: "/etc/chromium/policies/managed/chromium-policies.json",
      url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/chromium-policies.json",
      permissions: "644",
      user: "root",
      group: "root"
    },
    {
      destination: "/etc/firefox/policies/policies.json",
      url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/firefox-policies.json",
      permissions: "644",
      user: "root",
      group: "root"
    },
    {
      destination: "/etc/chrony.d/dhcp.conf",
      url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/chrony-dhcp.conf",
      permissions: "644",
      user: "root",
      group: "root"
    }
  ]
}
