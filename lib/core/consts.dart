import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

abstract class Consts {
  static const appName = 'IntelliTask';

  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvYm1hZ3ZvdWFoaWZ4dHdrbHFvIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODE1ODEyNDIsImV4cCI6MTk5NzE1NzI0Mn0.y3-Or79Zl9Rf-crMMlub6JTQwHX_U5fikNsxDmCaQRQ';
  static const supabaseUrl = 'https://vobmagvouahifxtwklqo.supabase.co';
  static final logger = Logger();

  static const tableTasks = 'tasks';
  static const tableTasksColumnId = 'id';
  static const tableTasksColumnData = 'data';
  static const tableTasksColumnPriority = 'priority';
  static const tableTasksColumnIsComplete = 'is_complete';
  static const tableTasksColumnIsCreatedAt = 'created_at';

  static const defaultAnimationDuration = Duration(milliseconds: 600);
  static const defaultAnimationCurve = Curves.easeInOut;
}
