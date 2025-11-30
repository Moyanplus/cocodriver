import 'package:flutter/material.dart';

/// 传输页：包含上传/下载/分享/回收站四个标签
class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: const [
          TabBar(
            labelColor: Colors.black87,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: '上传'),
              Tab(text: '下载'),
              Tab(text: '分享'),
              Tab(text: '垃圾站'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TransferPlaceholder(title: '上传任务'),
                _TransferPlaceholder(title: '下载任务'),
                _TransferPlaceholder(title: '分享记录'),
                _TransferPlaceholder(title: '垃圾站'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferPlaceholder extends StatelessWidget {
  const _TransferPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title（待接入数据）',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
