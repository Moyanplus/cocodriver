#!/usr/bin/env python3
"""
网页 Icon 获取工具

功能：
1. 从网页 HTML 中解析 favicon 链接
2. 尝试获取根目录的 /favicon.ico
3. 支持相对路径和绝对路径
4. 下载并保存 favicon

使用方法：
    python get_website_icon.py <url> [output_path]

示例：
    python get_website_icon.py https://www.google.com
    python get_website_icon.py https://www.baidu.com ./icons/baidu.ico
"""

import argparse
import os
import sys
from urllib.parse import urljoin, urlparse
import requests
from bs4 import BeautifulSoup


class FaviconFetcher:
    """Favicon 获取器"""
    
    def __init__(self, url: str, timeout: int = 10):
        """
        初始化
        
        Args:
            url: 目标网页 URL
            timeout: 请求超时时间（秒）
        """
        self.url = url
        self.timeout = timeout
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
                         'AppleWebKit/537.36 (KHTML, like Gecko) '
                         'Chrome/120.0.0.0 Safari/537.36'
        })
    
    def get_base_url(self) -> str:
        """获取基础 URL（协议 + 域名）"""
        parsed = urlparse(self.url)
        return f"{parsed.scheme}://{parsed.netloc}"
    
    def fetch_favicon_from_html(self) -> list:
        """
        从 HTML 中解析 favicon 链接
        
        Returns:
            favicon URL 列表，按优先级排序
        """
        try:
            response = self.session.get(self.url, timeout=self.timeout)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            favicon_urls = []
            
            # 查找所有可能的 favicon 标签
            # 优先级：icon > shortcut icon > apple-touch-icon
            selectors = [
                ('link', {'rel': 'icon'}),
                ('link', {'rel': 'shortcut icon'}),
                ('link', {'rel': 'apple-touch-icon'}),
                ('link', {'rel': 'apple-touch-icon-precomposed'}),
            ]
            
            for tag, attrs in selectors:
                elements = soup.find_all(tag, attrs)
                for element in elements:
                    href = element.get('href')
                    if href:
                        # 转换为绝对 URL
                        absolute_url = urljoin(self.url, href)
                        if absolute_url not in favicon_urls:
                            favicon_urls.append(absolute_url)
            
            return favicon_urls
            
        except Exception as e:
            print(f"从 HTML 解析 favicon 失败: {e}", file=sys.stderr)
            return []
    
    def get_default_favicon_url(self) -> str:
        """获取默认的 favicon.ico URL"""
        return urljoin(self.get_base_url(), '/favicon.ico')
    
    def download_favicon(self, favicon_url: str) -> bytes:
        """
        下载 favicon
        
        Args:
            favicon_url: favicon URL
            
        Returns:
            favicon 二进制数据
        """
        try:
            response = self.session.get(favicon_url, timeout=self.timeout)
            response.raise_for_status()
            
            # 检查内容类型
            content_type = response.headers.get('Content-Type', '')
            if 'image' not in content_type and 'icon' not in content_type:
                print(f"警告: {favicon_url} 的内容类型可能不是图片: {content_type}")
            
            return response.content
            
        except Exception as e:
            raise Exception(f"下载 favicon 失败: {e}")
    
    def fetch(self) -> tuple:
        """
        获取 favicon
        
        Returns:
            (favicon_data, favicon_url) 元组
        """
        # 1. 尝试从 HTML 中获取
        print(f"正在访问: {self.url}")
        favicon_urls = self.fetch_favicon_from_html()
        
        if favicon_urls:
            print(f"从 HTML 中找到 {len(favicon_urls)} 个 favicon 链接")
            for i, url in enumerate(favicon_urls, 1):
                try:
                    print(f"尝试下载 ({i}/{len(favicon_urls)}): {url}")
                    data = self.download_favicon(url)
                    if data:
                        print(f"✓ 成功获取 favicon ({len(data)} 字节)")
                        return data, url
                except Exception as e:
                    print(f"✗ 失败: {e}")
                    continue
        
        # 2. 尝试默认的 /favicon.ico
        default_url = self.get_default_favicon_url()
        print(f"尝试默认路径: {default_url}")
        try:
            data = self.download_favicon(default_url)
            if data:
                print(f"✓ 成功获取 favicon ({len(data)} 字节)")
                return data, default_url
        except Exception as e:
            print(f"✗ 失败: {e}")
        
        raise Exception("无法获取 favicon")
    
    def save_favicon(self, output_path: str = None) -> str:
        """
        获取并保存 favicon
        
        Args:
            output_path: 输出路径，如果为 None 则自动生成
            
        Returns:
            保存的文件路径
        """
        data, favicon_url = self.fetch()
        
        # 确定输出路径
        if output_path is None:
            # 从 URL 中提取域名作为文件名
            parsed = urlparse(self.url)
            domain = parsed.netloc.replace('www.', '')
            
            # 尝试从 favicon URL 中获取扩展名
            favicon_ext = os.path.splitext(urlparse(favicon_url).path)[1]
            if not favicon_ext or favicon_ext == '.':
                favicon_ext = '.ico'
            
            output_path = f"{domain}{favicon_ext}"
        
        # 创建目录
        output_dir = os.path.dirname(output_path)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        # 保存文件
        with open(output_path, 'wb') as f:
            f.write(data)
        
        print(f"✓ Favicon 已保存到: {output_path}")
        return output_path


def main():
    """主函数"""
    parser = argparse.ArgumentParser(
        description='获取网页的 favicon 图标',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  %(prog)s https://www.google.com
  %(prog)s https://www.baidu.com ./icons/baidu.ico
  %(prog)s https://github.com -o github.png
        """
    )
    
    parser.add_argument('url', help='目标网页 URL')
    parser.add_argument('output', nargs='?', help='输出文件路径（可选）')
    parser.add_argument('-o', '--output-path', dest='output_alt', help='输出文件路径（替代参数）')
    parser.add_argument('-t', '--timeout', type=int, default=10, help='请求超时时间（秒），默认 10')
    
    args = parser.parse_args()
    
    # 确定输出路径
    output_path = args.output or args.output_alt
    
    # 验证 URL
    url = args.url
    if not url.startswith(('http://', 'https://')):
        url = 'https://' + url
    
    try:
        fetcher = FaviconFetcher(url, timeout=args.timeout)
        saved_path = fetcher.save_favicon(output_path)
        print(f"\n成功! 文件路径: {os.path.abspath(saved_path)}")
        return 0
        
    except Exception as e:
        print(f"\n错误: {e}", file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())

