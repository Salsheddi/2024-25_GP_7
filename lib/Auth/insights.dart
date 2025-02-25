import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class insights extends StatefulWidget {
  const insights({super.key});

  @override
  State<insights> createState() => _insightsState();
}

class _insightsState extends State<insights>
    with SingleTickerProviderStateMixin {
  @override
  late TabController _tabController;
  int selectedIndex = 0;
  String selectedPeriod = "Weekly";
  final List<String> options = ["Weekly", "Monthly", "Yearly"];

  int totalMessages = 0;
  int legitMessages = 0;
  int spamMessages = 0;
  int reportedSpamMessages = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedIndex = _tabController.index;
      });
      fetchMessages(); // This will now only be called after _tabController is initialized
    });
    // Load data after the tab controller is initialized
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DateTime now = DateTime.now();
      DateTime startDate = getStartDate(selectedIndex, now);

      // Fetch classified messages (Legit & Spam)
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("messages")
          .where("userId", isEqualTo: user.uid)
          .where("timestamp", isGreaterThanOrEqualTo: startDate)
          .get();

      int total = querySnapshot.docs.length;
      int legit = 0;
      int spam = 0;

      for (var doc in querySnapshot.docs) {
        String label = doc["label"];
        if (label == "Not Spam") {
          legit++;
        } else if (label == "Spam") {
          spam++;
        }
      }

      // Fetch the number of spam messages the user has reported
      QuerySnapshot reportedQuery = await FirebaseFirestore.instance
          .collection("reportedMessagesSummary")
          .where("reportedUsers",
              arrayContains: user.uid) // Check if user reported
          .get();

      int reportedCount = reportedQuery.docs.length;

      setState(() {
        totalMessages = total;
        legitMessages = legit;
        spamMessages = spam;
        reportedSpamMessages = reportedCount; // Store the reported count
      });
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  DateTime getStartDate(int index, DateTime now) {
    if (index == 0) {
      return now.subtract(Duration(days: 7)); // Weekly
    } else if (index == 1) {
      return DateTime(now.year, now.month, 1); // Monthly
    } else {
      return DateTime(now.year, 1, 1); // Yearly
    }
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Adjust based on the number of tabs
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: const Color(0xFF2184FC).withOpacity(0.76),
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 63.0, left: 16.0, right: 16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Message Insights",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 115.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Color(0xFFF7F6F6),
                ),
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      indicatorColor: Colors.blue,
                      labelStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: TextStyle(fontSize: 14),
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(text: "Weekly"),
                        Tab(text: "Monthly"),
                        Tab(text: "Yearly"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          WeeklyTab(),
                          MonthlyTab(),
                          YearlyTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget WeeklyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 8),
          _buildChart(),
          _buildStats(),
          buildReportedMessages(),
          buildReportedMessagess(),
          buildUsagePatternChart("weekly"),
        ],
      ),
    );
  }

  Widget MonthlyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 8),
          _buildChart(),
          _buildStats(),
          buildUsagePatternChart("monthly"),
        ],
      ),
    );
  }

  Widget YearlyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 8),
          _buildChart(),
          _buildStats(),
          buildUsagePatternChart("yearly"),
        ],
      ),
    );
  }

  Widget _buildStats() {
    double legitPercentage =
        totalMessages > 0 ? (legitMessages / totalMessages) * 100 : 0;
    double spamPercentage =
        totalMessages > 0 ? (spamMessages / totalMessages) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Messages Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    "$totalMessages",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Total Messages",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Divider(thickness: 1, color: Colors.grey.shade300),
            _buildCategoryRow(
                "Legitimate", legitMessages, legitPercentage, Colors.green),
            _buildCategoryRow(
                "Spam", spamMessages, spamPercentage, Color(0xFF2184FC)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
      String label, int count, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 18),
            ),
          ),
          Text(
            "${percentage.toStringAsFixed(1)}%",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Messages Classification",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: legitMessages.toDouble(),
                      color: Colors.green,
                      title: '${legitMessages.toString()}',
                      radius: 60,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: spamMessages.toDouble(),
                      color: Color(0xFF2184FC),
                      title: '${spamMessages.toString()}',
                      radius: 60,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReportedMessages() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reported Messages",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 200, // Adjust chart height
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        // Total Messages Bar
                        BarChartRodData(
                          toY: totalMessages.toDouble(),
                          color: Colors.grey,
                          width: 15,
                        ),
                        // Reported Messages Bar (Overlay)
                        BarChartRodData(
                          toY: reportedSpamMessages.toDouble(),
                          color: Colors.redAccent,
                          width: 15,
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text("Spam Reports",
                              style: TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Reported Spam: $reportedSpamMessages / $totalMessages",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              "This chart compares the total messages you have received with the messages you have reported as spam. "
              "The gray bar represents the total messages, while the red bar highlights the spam messages you reported. "
              "Use this insight to monitor your spam reporting activity.",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReportedMessagess() {
    double reportRatio =
        totalMessages > 0 ? reportedSpamMessages / totalMessages : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reported Messages",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: reportRatio,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
              minHeight: 15,
              borderRadius: BorderRadius.circular(10),
            ),
            SizedBox(height: 10),
            Text(
              "Reported Spam: $reportedSpamMessages / $totalMessages",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              "The progress bar shows the proportion of messages you have reported as spam. "
              "A higher filled portion means more spam reports.",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUsagePatternChart(String timePeriod) {
    DateTime startDate;

    // Define the start date based on the selected time period
    if (timePeriod == "weekly") {
      startDate = DateTime.now()
          .subtract(Duration(days: 7))
          .toLocal(); // Adjust to local time
    } else if (timePeriod == "monthly") {
      startDate = DateTime(DateTime.now().year, DateTime.now().month, 1)
          .toLocal(); // Adjust to local time
    } else {
      // yearly
      startDate =
          DateTime(DateTime.now().year, 1, 1).toLocal(); // Adjust to local time
    }

    print("Start Date for $timePeriod: $startDate"); // Debug log

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("messages")
          .where("timestamp",
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy("timestamp",
              descending: false) // Ensure sorting by timestamp
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        Map<String, int> legitCounts = {};
        Map<String, int> spamCounts = {};
        Map<String, int> totalCounts = {};

        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime timestamp = (data["timestamp"] as Timestamp).toDate();
          String date = DateFormat('yyyy-MM-dd').format(timestamp);

          print("Fetched doc date: $date, Timestamp: $timestamp"); // Debug log

          if (!totalCounts.containsKey(date)) {
            totalCounts[date] = 0;
            spamCounts[date] = 0;
            legitCounts[date] = 0;
          }

          totalCounts[date] = (totalCounts[date]! + 1);
          if (data["label"] == "Spam") {
            spamCounts[date] = (spamCounts[date]! + 1);
          } else {
            legitCounts[date] = (legitCounts[date]! + 1);
          }
        }

        List<String> sortedDates = totalCounts.keys.toList()..sort();
        List<FlSpot> legitSpots = [];
        List<FlSpot> spamSpots = [];
        List<FlSpot> totalSpots = [];

        for (int i = 0; i < sortedDates.length; i++) {
          String date = sortedDates[i];
          legitSpots.add(FlSpot(i.toDouble(), legitCounts[date]!.toDouble()));
          spamSpots.add(FlSpot(i.toDouble(), spamCounts[date]!.toDouble()));
          totalSpots.add(FlSpot(i.toDouble(), totalCounts[date]!.toDouble()));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Fraud Detector Usage Pattern",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString(),
                                  style: TextStyle(fontSize: 12));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              return index < sortedDates.length
                                  ? Text(sortedDates[index].substring(5),
                                      style: TextStyle(fontSize: 10))
                                  : Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: legitSpots,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          belowBarData: BarAreaData(show: false),
                        ),
                        LineChartBarData(
                          spots: spamSpots,
                          isCurved: true,
                          color: Colors.redAccent,
                          barWidth: 3,
                          belowBarData: BarAreaData(show: false),
                        ),
                        LineChartBarData(
                          spots: totalSpots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "This chart tracks your daily AI fraud detector usage. Green represents legitimate messages, "
                  "red indicates spam detections, and blue shows total messages analyzed.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
