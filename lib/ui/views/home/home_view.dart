import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  final String selfCallerId;
  const HomeView({Key? key, required this.selfCallerId}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("P2P Call App"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: TextEditingController(
                        text: viewModel.selfCallerId,
                      ),
                      readOnly: true,
                      textAlign: TextAlign.center,
                      enableInteractiveSelection: false,
                      decoration: InputDecoration(
                        labelText: "Your Caller ID",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: viewModel.remoteCallerIdTextEditingController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Remote Caller ID",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                      ),
                      child: const Text(
                        "Invite",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        viewModel.joinCall(
                          context: context,
                          calleeId: viewModel
                              .remoteCallerIdTextEditingController.text,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (viewModel.incomingSDPOffer != null)
              Positioned(
                child: ListTile(
                  title: Text(
                    "Incoming Call from ${viewModel.incomingSDPOffer["callerId"]}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call_end),
                        color: Colors.redAccent,
                        onPressed: viewModel.rejectCall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.call),
                        color: Colors.greenAccent,
                        onPressed: () {
                          viewModel.joinCall(
                            context: context,
                            calleeId: viewModel.selfCallerId,
                            offer: viewModel.incomingSDPOffer["sdpOffer"],
                          );
                        },
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

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel(selfCallerId);
}
