import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '/product_details.dart';
import 'api_service/api.dart';
import 'model/product.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  // Get all products from server
  Future<List<Product>> getAllProducts() async {
    List<Product> productList = [];

    try {
      final url = Uri.parse(Api.getAllProducts);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        for (var eachRecord in (responseData as List)) {
          productList.add(Product.fromJson(eachRecord));
        }
      } else {
        Fluttertoast.showToast(msg: "error");
      }
    } catch (errorMsg) {
      Fluttertoast.showToast(msg: "error");
    }

    return productList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent, // Updated background color
        title: const Center(
          child: Text(
            'Product List',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            FutureBuilder(
                future: getAllProducts(),
                builder: (context, AsyncSnapshot<List<Product>> dataSnapShot) {
                  if (dataSnapShot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (dataSnapShot.data == null) {
                    return Center(
                      child: Text(
                        "Empty. No data found!",
                      ),
                    );
                  }
                  if (dataSnapShot.data!.isNotEmpty) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        double cardWidth = constraints.maxWidth * 0.85; // 85% of screen width

                        return Column(
                          children: dataSnapShot.data!.map((eachProduct) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(ProductDetails(productInfo: eachProduct));
                              },
                              child: Center( // Center the card
                                child: Container(
                                  width: cardWidth, // Set the card width to be responsive
                                  margin: const EdgeInsets.symmetric(vertical: 8.0), // Vertical margin for spacing
                                  child: Card(
                                    elevation: 3,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0), // Reduce padding
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread items evenly
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // Product Image
                                          Hero(
                                            tag: eachProduct.image!,
                                            child: CachedNetworkImage(
                                              imageUrl: eachProduct.image!,
                                              placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                              errorWidget: (context, url, error) => const Icon(Icons.error),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          // Spacer
                                          const SizedBox(height: 10),
                                          // Product Title
                                          Text(
                                            eachProduct.title!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 2,
                                          ),
                                          // Spacer
                                          const SizedBox(height: 5),
                                          // Product Price
                                          Text(
                                            "Tk ${eachProduct.price}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text("Empty. No data found!"),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}