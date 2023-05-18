import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class Consts {
  const Consts._();
  static const appName = 'IntelliTask';

  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvYm1hZ3ZvdWFoaWZ4dHdrbHFvIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODE1ODEyNDIsImV4cCI6MTk5NzE1NzI0Mn0.y3-Or79Zl9Rf-crMMlub6JTQwHX_U5fikNsxDmCaQRQ';
  static const supabaseUrl = 'https://vobmagvouahifxtwklqo.supabase.co';
  static final logger = Logger();

  static const tblTasks = 'tasks';
  static const tblTasksColId = 'id';
  static const tblTasksColData = 'data';
  static const tblTasksColPriority = 'priority';
  static const tblTasksColIsComplete = 'is_complete';
  static const tblTasksColCreatedAt = 'created_at';

  static const defaultAnimationDuration = Duration(milliseconds: 600);
  static const defaultAnimationDurationHalf = Duration(milliseconds: 300);
  static const defaultAnimationCurve = Curves.easeInOut;
}
