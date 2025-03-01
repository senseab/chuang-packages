{ pkgs, ... }:
{
  # 导入安装包
  inode-client = pkgs.callPackage ./inode-client/package.nix { };
}
