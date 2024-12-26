import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Garbage Collection History',
          style: GoogleFonts.raleway(textStyle: const TextStyle(color: Colors.black)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('garbage_collection').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final data = snapshot.data?.docs;

            return ListView.builder(
              itemCount: data?.length ?? 0,
              itemBuilder: (context, index) {
                final doc = data![index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      'Location: ${doc['location']['name']}', // Display location name only
                      style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Coordinates: ${doc['location']['coordinates']['latitude']}, ${doc['location']['coordinates']['longitude']}', style: TextStyle(fontSize: 16)),
                        Text('Sensor 1 Level: ${doc['sensor1_level']}%', style: TextStyle(fontSize: 16)),
                        Text('Sensor 2 Level: ${doc['sensor2_level']}%', style: TextStyle(fontSize: 16)),
                        Text('Collection Time: ${_formatDate(doc['collection_time'])}', style: TextStyle(fontSize: 16)),
                        Text('Status: ${doc['is_empty'] ? "Empty" : "Not Empty"}', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: doc['is_empty'] ? null : () => _reportCollection(doc.id, context),
                      child: const Text('Report Collection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: doc['is_empty'] ? Colors.grey : Colors.blue,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "N/A";
    return DateFormat('yyyy-MM-dd – HH:mm').format(timestamp.toDate());
  }

  Future<void> _reportCollection(String docId, BuildContext context) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('garbage_collection').doc(docId).get();
      if (!doc.exists || doc['is_empty']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot report collection for an empty garbage can.')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('collection_history').add({
        'location': doc['location'],
        'sensor1_level': doc['sensor1_level'],
        'sensor2_level': doc['sensor2_level'],
        'collection_time': FieldValue.serverTimestamp(),
        'is_empty': true,
      });

      await FirebaseFirestore.instance.collection('garbage_collection').doc(docId).update({
        'is_empty': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collection reported successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reporting collection: $e')),
      );
    }
  }
}