import 'package:flutter/material.dart';

import '../../domain/entities/workshop_job.dart';
import '../controllers/workshop_job_controller.dart';

class WorkshopPage extends StatefulWidget {
  const WorkshopPage({super.key});

  @override
  State<WorkshopPage> createState() => _WorkshopPageState();
}

class _WorkshopPageState extends State<WorkshopPage> {
  static const String companyId = 'extincendios';

  final WorkshopJobController _controller = WorkshopJobController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<WorkshopJob>>(
        stream: _controller.watchWorkshopJobs(
          companyId: companyId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erro ao carregar as obras:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final jobs = snapshot.data ?? [];

          if (jobs.isEmpty) {
            return const Center(
              child: Text(
                'Ainda não existem obras.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(
                    Icons.engineering_rounded,
                  ),
                  title: Text(
                    job.jobNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(job.clientName),
                      Text(job.compressorName),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(job.statusLabel),
                  ),
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }
}