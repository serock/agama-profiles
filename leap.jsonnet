local agama = import "hw.libsonnet";
local board = agama.findByID(agama.lshw, "core").product;
local getHostname(motherboard) =
  if motherboard == "PRIME H370M-PLUS" then
    "desktop"
  else if motherboard == "4239CTO" then
    "laptop15"
  else if motherboard == "IPXBD-RB" then
    "mini"
  else if motherboard == "VirtualBox" then
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
  hostname: {
    static: getHostname(board)
  },
  network: {
    connections: [
      {
        id: "Wired connection 1",
        method4: "auto",
        match: {
          driver: ["e1000e", "e1000"]
        }
      }
    ]
  },
  scripts: {
    post: [
      {
        name: "nm",
        url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/network-manager.sh"
      }
    ],
    init: [
      {
        name: "nm-radio",
        url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/nm-radio.sh"
      },
      {
        name: "cdn",
        url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/cdn.sh"
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
    ]
  }
}

