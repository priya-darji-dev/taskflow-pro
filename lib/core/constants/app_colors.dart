import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Brand Accent (Electric Indigo & Violet)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color accent = Color(0xFF8B5CF6);

  // Dark Theme Tokens (Obsidian & Slate)
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Theme Tokens (Alabaster & Pure White)
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Task Priority Semantic Colors
  static const Color priorityLow = Color(0xFF10B981);    // Emerald Green
  static const Color priorityMedium = Color(0xFF3B82F6); // Royal Blue
  static const Color priorityHigh = Color(0xFFF59E0B);   // Amber Orange
  static const Color priorityUrgent = Color(0xFFEF4444); // Coral Red

  // Status Semantic Colors
  static const Color statusTodo = Color(0xFF64748B);
  static const Color statusInProgress = Color(0xFF6366F1);
  static const Color statusDone = Color(0xFF10B981);

  // Curated Board Accent Swatches (Users can pick these when creating a board)
  static const List<int> boardColorSwatches = [
    0xFF6366F1, // Indigo
    0xFFEC4899, // Pink
    0xFF10B981, // Emerald
    0xFFF59E0B, // Amber
    0xFF3B82F6, // Blue
    0xFF8B5CF6, // Purple
    0xFF14B8A6, // Teal
    0xFFEF4444, // Red
  ];
}