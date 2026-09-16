import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../models/check_record.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentMonth = DateTime.now();
  Map<String, List<CheckRecord>> recordMap = {};

  @override
  void initState() {
    super.initState();
    loadAllRecords();
  }

  Future loadAllRecords() async {
    final list = await DbService.instance.getAllRecords();
    Map<String, List<CheckRecord>> map = {};
    for(var r in list){
      if(!map.containsKey(r.date)) map[r.date] = [];
      map[r.date]!.add(r);
    }
    setState(() => recordMap = map);
  }

  Widget buildCalendarGrid() {
    final year = currentMonth.year;
    final month = currentMonth.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final weekday = firstDay.weekday;
    final totalDays = lastDay.day;
    List<Widget> cells = [];
    for(int i=1; i<weekday; i++) cells.add(const SizedBox());
    for(int d=1; d<=totalDays; d++){
      String dateStr = DateFormat("yyyy-MM-dd").format(DateTime(year,month,d));
      bool hasComplete = recordMap[dateStr]?.any((r)=>r.status=="complete") ?? false;
      bool hasMiss = recordMap[dateStr]?.any((r)=>r.status=="miss") ?? false;
      Color dotColor = Colors.transparent;
      if(hasComplete) dotColor = Colors.green;
      if(hasMiss) dotColor = Colors.red;
      return InkWell(
        onTap: (){
          final recs = recordMap[dateStr] ?? [];
          showDialog(context: context, builder: (ctx)=>AlertDialog(
            title: Text(dateStr),
            content: SizedBox(width:300, child: recs.isEmpty ? const Text("当日无打卡记录") : Column(mainAxisSize: MainAxisSize.min,
              children: recs.map((r)=>Text("任务${r.taskId}：${r.status} 备注：${r.note}")).toList()
            )),
            actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("关闭"))],
          ));
        },
        child: Container(alignment: Alignment.center, child: Stack(children:[
          Text("$d"),
          Positioned(bottom:2, child: Container(width:6,height:6,decoration: BoxDecoration(color:dotColor,shape:BoxShape.circle)))
        ]))
      );
    }
    return GridView.count(crossAxisCount:7, shrinkWrap:true, children:cells);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("打卡日历")),
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(onPressed: ()=>setState(()=>currentMonth = DateTime(currentMonth.year, currentMonth.month-1)), icon: const Icon(Icons.arrow_left)),
          Text(DateFormat("yyyy年MM月").format(currentMonth), style: const TextStyle(fontSize:18)),
          IconButton(onPressed: ()=>setState(()=>currentMonth = DateTime(currentMonth.year, currentMonth.month+1)), icon: const Icon(Icons.arrow_right)),
        ]),
        const Padding(padding: EdgeInsets.symmetric(vertical:8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children:[Text("一"),Text("二"),Text("三"),Text("四"),Text("五"),Text("六"),Text("日")])),
        Expanded(child: SingleChildScrollView(child: buildCalendarGrid()))
      ]),
    );
  }
}
