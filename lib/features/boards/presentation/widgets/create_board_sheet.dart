import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/board_model.dart';
import '../controllers/board_controller.dart';

class CreateBoardSheet extends StatefulWidget {
  final BoardModel? boardToEdit;

  const CreateBoardSheet({super.key, this.boardToEdit});

  @override
  State<CreateBoardSheet> createState() => _CreateBoardSheetState();
}

class _CreateBoardSheetState extends State<CreateBoardSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late int _selectedColor;

  bool get isEditing => widget.boardToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.boardToEdit?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.boardToEdit?.description ?? '',
    );
    _selectedColor =
        widget.boardToEdit?.colorHex ?? AppColors.boardColorSwatches.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final controller = Get.find<BoardController>();
      if (isEditing) {
        controller.updateBoard(
          board: widget.boardToEdit!,
          title: _titleController.text,
          description: _descController.text,
          colorHex: _selectedColor,
        );
      } else {
        controller.createBoard(
          title: _titleController.text,
          description: _descController.text.isEmpty
              ? 'No description provided'
              : _descController.text,
          colorHex: _selectedColor,
        );
      }
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                      isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEditing
                      ? 'Edit Workspace Board'
                      : 'Create New Workspace Board',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  autofocus: !isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Board Title',
                    hintText: 'e.g., Sprint 15 Roadmap',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is the focus of this board?',
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Accent Color',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppColors.boardColorSwatches.map((hex) {
                    final isSelected = _selectedColor == hex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = hex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(hex),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: Color(hex).withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _submit,
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Board',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}