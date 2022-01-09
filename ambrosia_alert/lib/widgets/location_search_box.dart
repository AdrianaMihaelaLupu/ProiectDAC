import 'package:flutter/material.dart';

class LocationSearchBox extends StatelessWidget {
  const LocationSearchBox({
    Key? key,
    required TextEditingController searchLocationController,
  })  : _searchLocationController = searchLocationController,
        super(key: key);

  final TextEditingController _searchLocationController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, 10),
              spreadRadius: 2,
            ),
          ]
        ),
        child: TextField(
          controller: _searchLocationController,
          autocorrect: false,
          autofocus: false,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            prefixIcon: Icon(Icons.search),
            suffixIconColor: Colors.green[700],
            hintText: 'Cauta o locatie...',
            hintStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(
              left: 20,
              right: 5,
              bottom: 5,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
