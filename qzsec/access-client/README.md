# 齐治/H3C 运维审计系统连接代理

> 一个用爱（和无数依赖）发电的协议解析工具 🔌

## 协议解析方法

本工具用于解析神秘代码 `accessclient://` 协议，整个过程堪比特工解码：

### URL 脱马甲 👗

```bash
# 去掉协议头，别问为什么设计成 base64 套 zlib，可能就是为了让你多掉两根头发
echo "accessclient://aGVsbG8gd29ybGQK" | sed 's|accessclient://||'
```

### 套娃解码 🪆

```bash
# 先 base64 解压（误），再zlib解压（其实顺序是对的）
base64 -d | minideflate -d
# 输出结果大概是：{"app":"putty","hn":"主机名","pn":22,...}
```

### JSON 解剖课 🔬

```bash
# 用 jq 提取参数，为什么不用 python 解析？问就是哲学问题
jq -r '.hn' # 提取主机名，hn大概是hostname的拼音缩写吧 (╯°□°）╯
```

## 依赖关系

本项目的依赖比我的择偶标准还复杂：

| 依赖包 | 生存必要性 | 吐槽指数 |
|----------------|--------------------------|--------|
| jq | JSON 解析界的瑞士军刀 | ⭐⭐⭐⭐ |
| zlib-ng | 数据压缩界的扫地僧 | ⭐⭐ |
| passh | 自动输密码的神器 | ⭐⭐⭐⭐ (再也不用担心手速跟不上密码输入了) |
| openssh | 老牌 SSH 工具，你值得拥有 | ⭐ |
| coreutils | Linux 工具集的瑞士军刀 | ⭐⭐⭐ |
| xdg-terminal-exec | 终端弹窗工具 | ⭐⭐ (没有它就像没有门的房间) |

## 打包说明

使用Nix打包就像玩乐高：

```bash
# 一键构建（如果网络不抽风的话）
nix-build package.nix

# 进入开发环境（准备好面对依赖地狱吧）
nix-shell -E 'with import <nixpkgs> {}; callPackage ./package.nix {}'
```

构建完成后：

- 可执行文件在 `result/bin` 等你临幸
- 桌面入口文件在 `result/share/applications` 躺平
  
## 免责声明

本工具对以下情况概不负责：

1. 因解析过于复杂导致的脱发问题
1. 看到 zlib-ng 的 `ng` 以为是下代技术结果发现还是 zlib 的失落感
1. 在自动输入密码时产生的"我到底是不是黑客"的幻觉
