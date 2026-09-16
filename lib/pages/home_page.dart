import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/check_record.dart';
import '../services/db_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> taskList = [];
  List<CheckRecord> todayRecords = [];
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    final tasks = await DbService.instance.getTaskList();
    final records = await DbService.instance.getRecordByDate(today);
    setState(() {
      taskList = tasks;
      todayRecords = records;
    });
  }

  CheckRecord? getRecord(int taskId) {
    for (var r in todayRecords) {
      if (r.taskId == taskId) return r;
    }
    return null;
  }

  Future changeStatus(Task task, String status) async {
    final rec = getRecord(task.id!);
    if (rec != null) {
      rec.status = status;
      await DbService.instance.updateRecord(rec);
    } else {
      await DbService.instance.addRecord(
        CheckRecord(taskId: task.id!, date: today, status: status, note: ""),
      );
    }
    loadData();
  }

  void showAddTaskDialog() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("新增任务"),
      content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: "任务名称")),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("取消")),
        TextButton(onPressed: ()async{
          if(ctrl.text.isNotEmpty){
            await DbService.instance.addTask(Task(name: ctrl.text));
            loadData();
          }
          Navigator.pop(ctx);
        }, child: const Text("添加"))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("今日打卡")),
      floatingActionButton: FloatingActionButton(onPressed: showAddTaskDialog, child: const Icon(Icons.add)),
      body: taskList.isEmpty ? const Center(child: Text("暂无任务，点右下角+新增")) : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: taskList.length,
        itemBuilder: (ctx, idx) {
          final task = taskList[idx];
          final rec = getRecord(task.id!);
          String statusText = "未打卡";
          if(rec?.status == "complete") statusText = "✅已完成";
          if(rec?.status == "miss") statusText = "⚠未完成";
          return Card(
            child: ListTile(
              title: Text(task.name),
              subtitle: Text(statusText),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(onPressed: ()=>changeStatus(task, "complete"), icon: const Icon(Icons.check_circle, color: Colors.green)),
                IconButton(onPressed: ()=>changeStatus(task, "miss"), icon: const Icon(Icons.cancel, color: Colors.red)),
                IconButton(onPressed: ()async{
                  await DbService.instance.deleteTask(task.id!);
                  loadData();
                }, icon: const Icon(Icons.delete, color: Colors.grey)),
              ]),
              onTap: ()async{
                final noteCtrl = TextEditingController(text: rec?.note ?? "");
                showDialog(context: context, builder: (c)=>AlertDialog(
                  title: Text("${task.name} 备注"),
                  content: TextField(controller: noteCtrl, maxLines:3),
                  actions: [
                    TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("关闭")),
                    TextButton(onPressed: ()async{
                      if(rec != null){
                        rec.note = noteCtrl.text;
                        await DbService.instance.updateRecord(rec);
                      }else{
                        await DbService.instance.addRecord(CheckRecord(taskId: task.id!, date: today, status:"none", note: noteCtrl.text));
                      }
                      loadData();
                      Navigator.pop(c);
                    }, child: const Text("保存"))
                  ],
                ));
              },
            ),
          );
        },
      ),
    );
  }
}
