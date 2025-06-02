class ApiConstants {
  static const String baseUrl =
      'http://10.0.2.2:8000/api'; // Pastikan ini sesuai dengan server Laravel Anda

  // --- Endpoint Autentikasi ---
  static const String registerEndpoint = '$baseUrl/register';
  static const String loginEndpoint = '$baseUrl/login';
  static const String logoutEndpoint = '$baseUrl/logout';
  static const String userEndpoint =
      '$baseUrl/user'; // Untuk mendapatkan info user yang sedang login

  // --- Endpoint Produk ---
  // Endpoint Publik (bisa diakses semua user, termasuk non-login)
  static const String productsEndpoint = '$baseUrl/products';
  static String productDetailEndpoint(String id) =>
      '$baseUrl/products/$id'; // Untuk GET detail produk

  // Endpoint Admin (membutuhkan otorisasi admin)
  static const String adminProductsEndpoint =
      '$baseUrl/admin/products'; // Untuk POST (Create Product)
  static String adminProductUpdateEndpoint(String id) =>
      '$baseUrl/admin/products/$id'; // Untuk PUT (Update Product)
  static String adminProductDeleteEndpoint(String id) =>
      '$baseUrl/admin/products/$id'; // Untuk DELETE (Delete Product)

  // --- Endpoint Kategori ---
  // Endpoint Publik
  static const String categoriesEndpoint = '$baseUrl/categories';
  static String categoryDetailEndpoint(String id) => '$baseUrl/categories/$id';

  // Endpoint Admin
  static const String adminCategoriesEndpoint = '$baseUrl/admin/categories';
  static String adminCategoryUpdateEndpoint(String id) =>
      '$baseUrl/admin/categories/$id';
  static String adminCategoryDeleteEndpoint(String id) =>
      '$baseUrl/admin/categories/$id';

  // --- Endpoint Subkategori ---
  // Endpoint Publik
  static const String subcategoriesEndpoint = '$baseUrl/subcategories';
  static String subcategoryDetailEndpoint(String id) =>
      '$baseUrl/subcategories/$id';

  // Endpoint Admin
  static const String adminSubcategoriesEndpoint =
      '$baseUrl/admin/subcategories';
  static String adminSubcategoryUpdateEndpoint(String id) =>
      '$baseUrl/admin/subcategories/$id';
  static String adminSubcategoryDeleteEndpoint(String id) =>
      '$baseUrl/admin/subcategories/$id';

  // --- Endpoint Tipe Produk ---
  // Endpoint Publik
  static const String productTypesEndpoint = '$baseUrl/product-types';
  static String productTypeDetailEndpoint(String id) =>
      '$baseUrl/product-types/$id';

  // Endpoint Admin
  static const String adminProductTypesEndpoint =
      '$baseUrl/admin/product-types';
  static String adminProductTypeUpdateEndpoint(String id) =>
      '$baseUrl/admin/product-types/$id';
  static String adminProductTypeDeleteEndpoint(String id) =>
      '$baseUrl/admin/product-types/$id';

  // --- Endpoint Warna ---
  // Endpoint Publik
  static const String coloursEndpoint = '$baseUrl/colours';
  static String colourDetailEndpoint(String id) => '$baseUrl/colours/$id';

  // Endpoint Admin
  static const String adminColoursEndpoint = '$baseUrl/admin/colours';
  static String adminColourUpdateEndpoint(String id) =>
      '$baseUrl/admin/colours/$id';
  static String adminColourDeleteEndpoint(String id) =>
      '$baseUrl/admin/colours/$id';

  // --- Endpoint Usages ---
  // Endpoint Publik
  static const String usagesEndpoint = '$baseUrl/usages';
  static String usageDetailEndpoint(String id) => '$baseUrl/usages/$id';

  // Endpoint Admin
  static const String adminUsagesEndpoint = '$baseUrl/admin/usages';
  static String adminUsageUpdateEndpoint(String id) =>
      '$baseUrl/admin/usages/$id';
  static String adminUsageDeleteEndpoint(String id) =>
      '$baseUrl/admin/usages/$id';

  // --- Endpoint Genders ---
  // Endpoint Publik
  static const String gendersEndpoint =
      '$baseUrl/genders'; // Tambahkan endpoint genders juga
  static String genderDetailEndpoint(String id) => '$baseUrl/genders/$id';

  // Endpoint Admin
  static const String adminGendersEndpoint = '$baseUrl/admin/genders';
  static String adminGenderUpdateEndpoint(String id) =>
      '$baseUrl/admin/genders/$id';
  static String adminGenderDeleteEndpoint(String id) =>
      '$baseUrl/admin/genders/$id';
}
