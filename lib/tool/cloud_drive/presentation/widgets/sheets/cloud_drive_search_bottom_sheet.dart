import 'package:flutter/material.dart';

import '../../../config/cloud_drive_ui_config.dart';

enum CloudDriveSearchMode { strategy, local }

enum CloudDriveSearchFileType {
  all,
  folder,
  document,
  media,
  image,
  archive,
}

class CloudDriveSearchConfig {
  const CloudDriveSearchConfig({
    required this.mode,
    required this.keyword,
    required this.fileType,
    required this.caseSensitive,
    required this.includeSubfolders,
    required this.searchDescription,
    required this.useRegex,
    required this.regexPattern,
    this.minSizeMB,
    this.maxSizeMB,
  });

  final CloudDriveSearchMode mode;
  final String keyword;
  final CloudDriveSearchFileType fileType;
  final bool caseSensitive;
  final bool includeSubfolders;
  final bool searchDescription;
  final bool useRegex;
  final String regexPattern;
  final double? minSizeMB;
  final double? maxSizeMB;

  @override
  String toString() {
    return 'CloudDriveSearchConfig(mode: $mode, keyword: $keyword, fileType: '
        '$fileType, caseSensitive: $caseSensitive, includeSubfolders: '
        '$includeSubfolders, searchDescription: $searchDescription, useRegex: '
        '$useRegex, regexPattern: $regexPattern, minSizeMB: $minSizeMB, '
        'maxSizeMB: $maxSizeMB)';
  }
}

Future<CloudDriveSearchConfig?> showCloudDriveSearchBottomSheet(
  BuildContext context, {
  CloudDriveSearchConfig? initial,
}) {
  return showModalBottomSheet<CloudDriveSearchConfig>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => CloudDriveSearchBottomSheet(
          initialConfig: initial,
        ),
  );
}

class CloudDriveSearchBottomSheet extends StatefulWidget {
  const CloudDriveSearchBottomSheet({
    super.key,
    this.initialConfig,
  });

  final CloudDriveSearchConfig? initialConfig;

  @override
  State<CloudDriveSearchBottomSheet> createState() =>
      _CloudDriveSearchBottomSheetState();
}

class _CloudDriveSearchBottomSheetState
    extends State<CloudDriveSearchBottomSheet> {
  late CloudDriveSearchMode _mode;
  late CloudDriveSearchFileType _fileType;
  late bool _caseSensitive;
  late bool _includeSubfolders;
  late bool _searchDescription;
  late bool _useRegex;
  late TextEditingController _keywordController;
  late TextEditingController _minSizeController;
  late TextEditingController _maxSizeController;
  bool _isAdvanced = false;

  @override
  void initState() {
    super.initState();
    final config = widget.initialConfig;
    _mode = config?.mode ?? CloudDriveSearchMode.strategy;
    _fileType = config?.fileType ?? CloudDriveSearchFileType.all;
    _caseSensitive = config?.caseSensitive ?? false;
    _includeSubfolders = config?.includeSubfolders ?? true;
    _searchDescription = config?.searchDescription ?? true;
    _useRegex = config?.useRegex ?? false;
    _keywordController = TextEditingController(text: config?.keyword ?? '');
    _minSizeController = TextEditingController(
      text: config?.minSizeMB?.toString() ?? '',
    );
    _maxSizeController = TextEditingController(
      text: config?.maxSizeMB?.toString() ?? '',
    );
    _isAdvanced = config != null;
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _minSizeController.dispose();
    _maxSizeController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _mode = CloudDriveSearchMode.strategy;
      _fileType = CloudDriveSearchFileType.all;
      _caseSensitive = false;
      _includeSubfolders = true;
      _searchDescription = true;
      _useRegex = false;
      _keywordController.clear();
      _minSizeController.clear();
      _maxSizeController.clear();
      _isAdvanced = false;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      CloudDriveSearchConfig(
        mode: _mode,
        keyword: _keywordController.text.trim(),
        fileType: _fileType,
        caseSensitive: _caseSensitive,
        includeSubfolders: _includeSubfolders,
        searchDescription: _searchDescription,
        useRegex: _useRegex,
        regexPattern: _keywordController.text.trim(),
        minSizeMB: double.tryParse(_minSizeController.text.trim()),
        maxSizeMB: double.tryParse(_maxSizeController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: CloudDriveUIConfig.spacingL,
            right: CloudDriveUIConfig.spacingL,
            top: CloudDriveUIConfig.spacingL,
            bottom: CloudDriveUIConfig.spacingL,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isAdvanced ? '高级搜索' : '搜索',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context, null),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isAdvanced) ...[
                  _buildModeToggle(),
                  const SizedBox(height: 12),
                ],
                _buildKeywordField(),
                if (_isAdvanced) ...[
                  const SizedBox(height: 12),
                  _buildFileTypeSelector(),
                  const SizedBox(height: 12),
                  _buildSwitches(),
                  const SizedBox(height: 12),
                  _buildSizeFilters(),
                  const SizedBox(height: 18),
                ],
                _buildActionRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    final labels = {
      CloudDriveSearchMode.strategy: '云盘策略搜索',
      CloudDriveSearchMode.local: '本地筛选',
    };
    return ToggleButtons(
      isSelected: labels.keys.map((mode) => _mode == mode).toList(),
      borderRadius: BorderRadius.circular(12),
      onPressed: (index) {
        setState(() {
          _mode = labels.keys.elementAt(index);
        });
      },
      children: labels.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(entry.value),
            ),
          )
          .toList(),
    );
  }

  Widget _buildKeywordField() {
    final theme = Theme.of(context);
    final suffixColor = _useRegex
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    Widget textField = TextField(
      controller: _keywordController,
      autofocus: true,
      decoration: InputDecoration(
        labelText: '搜索关键词',
        hintText: _useRegex
            ? '正则表达式，如 (?i)^report.*2024'
            : '文件名、描述等关键词',
        border: null,
        suffixIcon: _isAdvanced
            ? IconButton(
                tooltip: _useRegex ? '正则匹配已启用' : '启用正则匹配',
                icon: Icon(
                  _useRegex ? Icons.code : Icons.code_off,
                  color: suffixColor,
                ),
                onPressed: () => setState(() => _useRegex = !_useRegex),
              )
            : null,
      ),
      textInputAction: TextInputAction.search,
    );

    if (!_isAdvanced) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textField,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _isAdvanced = true),
              icon: const Icon(Icons.tune),
              label: const Text('高级筛选'),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textField,
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _useRegex ? 1 : 0,
                child: _useRegex
                    ? const Text(
                        '已启用正则，遵循 Dart 正则语法。',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _isAdvanced = false),
              icon: const Icon(Icons.expand_less),
              label: const Text('收起高级'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileTypeSelector() {
    final labels = {
      CloudDriveSearchFileType.all: '全部',
      CloudDriveSearchFileType.folder: '仅文件夹',
      CloudDriveSearchFileType.document: '文档',
      CloudDriveSearchFileType.media: '音视频',
      CloudDriveSearchFileType.image: '图片',
      CloudDriveSearchFileType.archive: '压缩包',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '目标类型',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: labels.entries.map((entry) {
            final selected = _fileType == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _fileType = entry.key;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '筛选选项',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildToggleChip(
              '包含子文件夹',
              _includeSubfolders,
              (value) => setState(() => _includeSubfolders = value),
            ),
            _buildToggleChip(
              '匹配描述/备注',
              _searchDescription,
              (value) => setState(() => _searchDescription = value),
            ),
            _buildToggleChip(
              '区分大小写',
              _caseSensitive,
              (value) => setState(() => _caseSensitive = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleChip(
    String label,
    bool selected,
    ValueChanged<bool> onChanged,
  ) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) => onChanged(value),
    );
  }

  Widget _buildSizeFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '文件大小过滤 (MB)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minSizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '最小',
                  hintText: '例如：1',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _maxSizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '最大',
                  hintText: '例如：1024',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    if (!_isAdvanced) {
      return FilledButton(
        onPressed: _apply,
        child: const Text('应用筛选'),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _reset,
            child: const Text('重置'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: _apply,
            child: const Text('应用筛选'),
          ),
        ),
      ],
    );
  }
}
