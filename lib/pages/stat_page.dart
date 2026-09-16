import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/check_record.dart';
import 'package:intl/intl.dart';

class StatPage extends StatefulWidget {
  const StatPage({super.key});
  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  int totalComplete = 0;
  int continueDays = 0;

  @override
  void initState() {
    super.initState();
    calcStat();
  }

  Future calcStat() async {
    final allRecords = await DbService.instance.getAllRecords();
    List<String> completeDate = [];
    for(var r in allRecords){
      if(r.status == "complete" && !completeDate.contains(r.date)) completeDate.add(r.date);
    }
    completeDate.sort();
    totalComplete = completeDate.length;
    int streak = 0;
    DateTime now = DateTime.now();
    for(int i=0;;i++){
      String d = DateFormat("yyyy-MM-dd").format(now.subtract(Duration(days:i)));
      if(completeDate.contains(d)) streak++;
      else break;
    }
    setState(() {
      continueDays = streak;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("打卡统计")),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("总打卡次数：$totalComplete", style: const TextStyle(fontSize: 22)),
        const SizedBox(height:20),
        Text("连续打卡天数：$continueDays", style: const TextStyle(fontSize:22)),
      ])),
    );
  }
}
