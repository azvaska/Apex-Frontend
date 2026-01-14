import 'package:flutter/material.dart';

import 'package:apex/features/assistente/data/assistente_repository.dart';
import 'package:apex/features/profilo/data/monitoring_repository.dart';

class AssistenteScreen extends StatefulWidget {
  const AssistenteScreen({super.key});

  @override
  State<AssistenteScreen> createState() => _AssistenteScreenState();
}

class _AssistenteScreenState extends State<AssistenteScreen> {
  final AssistenteRepository _repository = AssistenteRepository();
  final MonitoringRepository _monitoringRepository = MonitoringRepository();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  List<_AreaChoice> _areas = const [];
  String? _selectedAreaId;
  String? _conversationId;
  bool _isSending = false;
  bool _isLoadingAreas = true;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAreas() async {
    try {
      final prefs = await _monitoringRepository.fetchPreferences();
      final choices = prefs
          .map(
            (pref) => _AreaChoice(id: pref.areaId, name: pref.areaName),
          )
          .toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _areas = choices;
        _selectedAreaId =
            choices.isNotEmpty ? choices.first.id : _selectedAreaId;
        _isLoadingAreas = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoadingAreas = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    if (_selectedAreaId == null) {
      _showError('Seleziona un\'area monitorata.');
      return;
    }
    setState(() {
      _messages.add(
        _ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: text,
          isUser: true,
          createdAt: DateTime.now(),
        ),
      );
      _controller.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final reply = await _repository.sendMessage(
        message: text,
        areaId: _selectedAreaId!,
        conversationId: _conversationId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _conversationId = reply.conversationId;
        _messages.add(
          _ChatMessage(
            id: reply.createdAt.microsecondsSinceEpoch.toString(),
            text: reply.answer,
            isUser: false,
            createdAt: reply.createdAt,
          ),
        );
      });
    } catch (error) {
      _showError('Errore: $error');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  'Assistente',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (_isLoadingAreas)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _AreaSelector(
              areas: _areas,
              selectedId: _selectedAreaId,
              onChanged: (value) => setState(() => _selectedAreaId = value),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _messages.isEmpty
                ? _EmptyChatState(
                    onExampleTap: (text) {
                      _controller.text = text;
                    },
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _ChatBubble(message: message);
                    },
                  ),
          ),
          _Composer(
            controller: _controller,
            isSending: _isSending,
            onSend: _sendMessage,
            enabled: _selectedAreaId != null,
          ),
        ],
      ),
    );
  }
}

class _AreaChoice {
  final String id;
  final String name;

  const _AreaChoice({required this.id, required this.name});
}

class _AreaSelector extends StatelessWidget {
  final List<_AreaChoice> areas;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _AreaSelector({
    required this.areas,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (areas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.place_outlined),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Nessuna area monitorata disponibile',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          isExpanded: true,
          items: areas
              .map(
                (area) => DropdownMenuItem(
                  value: area.id,
                  child: Text(area.name),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  final ValueChanged<String> onExampleTap;

  const _EmptyChatState({required this.onExampleTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'Chiedi un consiglio rapido',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scrivi un messaggio per ottenere indicazioni operative.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ExampleChip(
                  label: 'Rischio valanghe oggi?',
                  onTap: onExampleTap,
                ),
                _ExampleChip(
                  label: 'Cosa controllare sul sentiero?',
                  onTap: onExampleTap,
                ),
                _ExampleChip(
                  label: 'Suggerisci piano rapido',
                  onTap: onExampleTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String label;
  final ValueChanged<String> onTap;

  const _ExampleChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () => onTap(label),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;
  final bool enabled;

  const _Composer({
    required this.controller,
    required this.onSend,
    required this.isSending,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                enabled: enabled && !isSending,
                decoration: InputDecoration(
                  hintText: 'Scrivi un messaggio...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: isSending || !enabled ? null : onSend,
              backgroundColor: theme.colorScheme.primary,
              child: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  const _ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignment =
        message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceVariant;
    final textColor =
        message.isUser ? theme.colorScheme.onPrimary : Colors.black87;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
