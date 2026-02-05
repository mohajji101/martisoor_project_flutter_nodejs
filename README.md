# DUKUMEENTI SHARAXAAD - RESTAURANT ORDERING SYSTEM
## Mashruuca MartiSoor Restaurant

---

## 📋 GUUD AHAAN MASHRUUCA

### Ujeedada Mashruuca
Mashruucan waa **Nidaamka Dalabka Cuntada Restoranka** (Restaurant Ordering System) oo loogu talagalay in macaamiisha ay si fudud ugu dalban karaan cunto online-ka, iyo in maamulayaashu ay maarayn karaan alaabta, dalabka, iyo isticmaalayaasha.

### Qaybaha Mashruuca
Mashruucan waxa uu ka kooban yahay **laba qaybood** oo kala ah:

1. **Backend (Node.js + Express + MongoDB)**
   - Server-ka API-ga
   - Xogta database-ka
   - Maamulka isticmaalayaasha iyo authentication

2. **Frontend (Flutter)**
   - Mobile application
   - User interface macaamiisha iyo maamulayaasha
   - Xiriirka backend API

---

## 🏗️ QAABDHISMEEDKA MASHRUUCA (PROJECT STRUCTURE)

```
Restaurant-Ordering-main/
│
├── backend/                          # Backend Server (Node.js)
│   ├── src/
│   │   ├── models/                   # Database Models (Mongoose)
│   │   │   ├── User.js              # Model isticmaalaha
│   │   │   ├── Product.js           # Model alaabta
│   │   │   ├── Order.js             # Model dalabka
│   │   │   ├── Category.js          # Model qaybaha cuntada
│   │   │   └── Settings.js          # Model settings-ka
│   │   │
│   │   ├── routes/                   # API Routes
│   │   │   ├── auth.routes.js       # Routes login/register
│   │   │   ├── product.routes.js    # Routes alaabta
│   │   │   ├── order.routes.js      # Routes dalabka
│   │   │   └── admin.routes.js      # Routes maamulka
│   │   │
│   │   ├── controllers/              # Business Logic
│   │   ├── middleware/               # Authentication & Validation
│   │   ├── config/                   # Database Configuration
│   │   └── app.js                    # Express App Setup
│   │
│   ├── scripts/
│   │   └── create_admin.js          # Script sameeynta admin user
│   ├── server.js                     # Entry point server-ka
│   ├── package.json                  # Dependencies backend
│   └── .env                          # Environment variables
│
└── frontend_flutter/                 # Frontend Mobile App (Flutter)
    ├── lib/
    │   ├── main.dart                 # Entry point app-ka
    │   │
    │   ├── screens/                  # UI Screens
    │   │   ├── auth/                 # Login/Register screens
    │   │   ├── home/                 # Home screen
    │   │   ├── product/              # Product details
    │   │   ├── cart/                 # Shopping cart
    │   │   ├── order/                # Order management
    │   │   ├── admin/                # Admin screens
    │   │   ├── profile/              # User profile
    │   │   └── splash/               # Splash screen
    │   │
    │   ├── controllers/              # GetX Controllers
    │   │   ├── auth_controller.dart  # Authentication logic
    │   │   ├── cart_controller.dart  # Cart management
    │   │   └── theme_controller.dart # Theme management
    │   │
    │   ├── providers/                # State Management
    │   ├── services/                 # API Services
    │   ├── widgets/                  # Reusable Widgets
    │   └── utils/                    # Utilities & Themes
    │
    ├── assets/                       # Images & Resources
    │   ├── logo/                     # Logo images
    │   └── product/                  # Product images
    │
    └── pubspec.yaml                  # Dependencies Flutter

```

---

## 🔑 QAYBAHA MUHIIMKA AH (KEY COMPONENTS)

### 1. BACKEND COMPONENTS

#### A. Database Models (Mongoose Schemas)

##### **User Model** (`User.js`)
```javascript
{
  name: String,              // Magaca isticmaalaha
  email: String,             // Email-ka
  password: String,          // Password (encrypted)
  role: String,              // Doorka: 'customer' ama 'admin'
  resetPasswordToken: String,
  resetPasswordExpires: Date
}
```

##### **Product Model** (`Product.js`)
```javascript
{
  title: String,             // Magaca cuntada
  price: Number,             // Qiimaha
  image: String,             // Sawirka URL
  category: String           // Qaybta (Pizza, Burger, iwm)
}
```

##### **Order Model** (`Order.js`)
```javascript
{
  items: [                   // Liiska alaabta la dalbaday
    {
      productId: String,
      title: String,
      price: Number,
      quantity: Number,
      image: String,
      lineTotal: Number
    }
  ],
  user: ObjectId,            // Reference to User
  userName: String,
  userEmail: String,
  subtotal: Number,          // Wadarta
  deliveryFee: Number,       // Kharashka delivery
  total: Number,             // Wadarta guud
  status: String,            // "Pending", "Completed", "Cancelled"
  createdAt: Date
}
```

##### **Category Model** (`Category.js`)
```javascript
{
  name: String,              // Magaca qaybta
  description: String        // Sharaxaad
}
```

#### B. API Routes

##### **Authentication Routes** (`auth.routes.js`)
- `POST /api/auth/register` - Diiwaangelinta isticmaalaha cusub
- `POST /api/auth/login` - Galitaanka isticmaalaha

##### **Product Routes** (`product.routes.js`)
- `GET /api/products` - Soo qaadista dhammaan alaabta
- `GET /api/products/:id` - Soo qaadista hal alaab
- `POST /api/products` - Ku darista alaab cusub (Admin only)
- `PUT /api/products/:id` - Wax ka beddelida alaab (Admin only)
- `DELETE /api/products/:id` - Tirtirida alaab (Admin only)

##### **Order Routes** (`order.routes.js`)
- `GET /api/orders` - Soo qaadista dalabka
- `POST /api/orders` - Sameeynta dalab cusub
- `PUT /api/orders/:id` - Wax ka beddelida dalabka

##### **Admin Routes** (`admin.routes.js`)
- `GET /api/admin/users` - Soo qaadista isticmaalayaasha
- `POST /api/admin/users` - Sameeynta isticmaale cusub
- `DELETE /api/admin/users/:id` - Tirtirida isticmaale
- `GET /api/admin/categories` - Soo qaadista qaybaha
- `POST /api/admin/categories` - Sameeynta qaybta cusub
- `DELETE /api/admin/categories/:id` - Tirtirida qaybta

#### C. Middleware
- **Authentication Middleware** - Hubinta in isticmaaluhu uu login yahay
- **Admin Middleware** - Hubinta in isticmaaluhu uu admin yahay
- **Validation Middleware** - Hubinta xogta la soo diro

---

### 2. FRONTEND COMPONENTS (Flutter)

#### A. State Management - GetX Controllers

##### **AuthController** (`auth_controller.dart`)
- Maamulka login/logout
- Kaydinta xogta isticmaalaha
- Hubinta authentication status

##### **CartController** (`cart_controller.dart`)
- Ku darista alaab cart-ka
- Ka saarida alaab cart-ka
- Xisaabinta wadarta
- Maamulka quantity

##### **ThemeController** (`theme_controller.dart`)
- Beddelka theme (Light/Dark mode)
- Kaydinta preferences

#### B. Main Screens

##### **Splash Screen**
- Screen-ka ugu horreeya marka app-ka la furo
- Loading animation

##### **Authentication Screens**
- **Login Screen** - Galitaanka isticmaalaha
- **Register Screen** - Diiwaangelinta isticmaale cusub
- **Forgot Password Screen** - Soo celinta password-ka

##### **Home Screen**
- Muujinta alaabta
- Filter by category
- Search functionality
- Navigation bar

##### **Product Detail Screen**
- Faahfaahinta alaabta
- Ku darista cart-ka
- Quantity selector

##### **Cart Screen**
- Muujinta alaabta cart-ka
- Wax ka beddelida quantity
- Tirtirida items
- Checkout button

##### **Order Screens**
- **My Orders** - Muujinta dalabka isticmaalaha
- **Order Details** - Faahfaahinta dalab
- **Order Confirmation** - Xaqiijinta dalabka

##### **Admin Screens**
- **Admin Dashboard** - Statistics iyo overview
- **Manage Products** - Maamulka alaabta
- **Manage Orders** - Maamulka dalabka
- **Manage Users** - Maamulka isticmaalayaasha
- **Manage Categories** - Maamulka qaybaha

##### **Profile Screen**
- Xogta isticmaalaha
- Settings
- Logout

#### C. Services

##### **API Service**
- HTTP requests to backend
- Error handling
- Token management

---

## 🔐 AUTHENTICATION & AUTHORIZATION

### Authentication Flow
1. Isticmaaluhu wuxuu soo galaa email iyo password
2. Backend wuxuu hubiyaa credentials-ka
3. Haddii ay saxda yihiin, backend wuxuu soo celiyaa JWT token
4. Frontend wuxuu kaydiyaa token-ka
5. Requests kasta oo soo socda waxaa lagu daraa token-ka headers-ka

### Authorization Levels
- **Customer** - Wuxuu arki karaa alaabta, ku dari karaa cart-ka, sameeyn karaa dalabka
- **Admin** - Wuxuu maarayn karaa dhammaan alaabta, dalabka, isticmaalayaasha, iyo qaybaha

---

## 📊 DATABASE SCHEMA

### Collections
1. **users** - Xogta isticmaalayaasha
2. **products** - Xogta alaabta
3. **orders** - Xogta dalabka
4. **categories** - Xogta qaybaha cuntada
5. **settings** - Settings-ka app-ka (delivery fee, iwm)

---

## 🚀 SIDEE LOO SHAQEEYO MASHRUUCA

### Prerequisites (Waxyaabaha Loo Baahan Yahay)
- Node.js (v14 ama ka sarreeya)
- MongoDB (local ama cloud - MongoDB Atlas)
- Flutter SDK (v3.9.2 ama ka sarreeya)
- Android Studio ama VS Code

### Backend Setup

1. **Gal folder-ka backend**
```bash
cd backend
```

2. **Install dependencies**
```bash
npm install
```

3. **Samee .env file**
```
PORT=5000
MONGODB_URI=mongodb://localhost:27017/restaurant
JWT_SECRET=your_secret_key_here
```

4. **Samee admin user**
```bash
npm run create-admin
```

5. **Bilow server-ka**
```bash
npm run dev        # Development mode
# ama
npm start          # Production mode
```

### Frontend Setup

1. **Gal folder-ka frontend**
```bash
cd frontend_flutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Bedel API URL**
- Fur `lib/services/api_service.dart`
- Bedel `baseUrl` si ay u tahay IP address-ka computer-kaaga

4. **Run app-ka**
```bash
flutter run
```

---

## 🎯 FEATURES (AWOODYADA)

### Macaamiisha (Customers)
✅ Diiwaangelinta iyo login
✅ Daawashada alaabta
✅ Raadinta cuntada
✅ Filter by category
✅ Ku darista cart-ka
✅ Sameeynta dalabka
✅ Daawashada dalabka hore
✅ Profile management
✅ Dark/Light theme

### Maamulayaasha (Admins)
✅ Ku darista/wax ka beddelida/tirtirida alaabta
✅ Maamulka dalabka (approve, cancel)
✅ Sameeynta/tirtirida isticmaalayaasha
✅ Maamulka qaybaha cuntada
✅ Dashboard with statistics
✅ Settings management (delivery fee)

---

## 🔧 TECHNOLOGIES USED

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM (Object Data Modeling)
- **JWT** - Authentication
- **bcryptjs** - Password encryption
- **CORS** - Cross-Origin Resource Sharing

### Frontend
- **Flutter** - UI framework
- **Dart** - Programming language
- **GetX** - State management
- **HTTP** - API calls
- **Device Preview** - Testing on multiple devices

---

## 📱 USER FLOWS

### Customer Flow
1. **Fur app-ka** → Splash Screen
2. **Login/Register** → Authentication
3. **Browse products** → Home Screen
4. **Select product** → Product Details
5. **Add to cart** → Cart Management
6. **Checkout** → Order Confirmation
7. **View orders** → My Orders Screen

### Admin Flow
1. **Login as admin** → Admin Dashboard
2. **Manage products** → Add/Edit/Delete products
3. **Manage orders** → View/Update order status
4. **Manage users** → Create/Delete users
5. **Manage categories** → Add/Delete categories

---

## 🐛 COMMON ISSUES & SOLUTIONS

### Backend Issues

**Issue 1: MongoDB connection failed**
- **Solution**: Hubi in MongoDB uu shaqeynayo
```bash
# Windows
net start MongoDB

# Mac/Linux
sudo systemctl start mongod
```

**Issue 2: Port already in use**
- **Solution**: Bedel PORT-ka `.env` file-ka

### Frontend Issues

**Issue 1: Cannot connect to backend**
- **Solution**: Hubi in backend server-ku uu shaqeynayo
- Hubi in API URL-ku uu saxan yahay

**Issue 2: Build failed**
- **Solution**: Clean iyo rebuild
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📝 TESTING

### Backend Testing
```bash
# Test API endpoints using Postman or curl
curl http://localhost:5000/api/products
```

### Frontend Testing
```bash
# Run in debug mode
flutter run

# Run tests
flutter test
```

---

## 🔄 FUTURE ENHANCEMENTS

### Waxyaabaha La Ku Dari Karo Mustaqbalka
- [ ] Payment integration (Stripe, PayPal)
- [ ] Push notifications
- [ ] Real-time order tracking
- [ ] Rating and reviews
- [ ] Multiple restaurant support
- [ ] Delivery driver app
- [ ] Analytics dashboard
- [ ] Email notifications
- [ ] SMS notifications
- [ ] Loyalty program

---

## 👥 USER ROLES & PERMISSIONS

### Customer Permissions
- ✅ View products
- ✅ Add to cart
- ✅ Place orders
- ✅ View own orders
- ✅ Update profile
- ❌ Access admin features

### Admin Permissions
- ✅ All customer permissions
- ✅ Manage products
- ✅ Manage orders (all)
- ✅ Manage users
- ✅ Manage categories
- ✅ View statistics
- ✅ Update settings

---

## 📞 SUPPORT & CONTACT

Haddii aad qabtid su'aalo ama aad u baahan tahay caawimaad:
- Eeg documentation-ka
- Raadi issues-ka GitHub
- Contact the development team

---

## 📄 LICENSE

This project is for educational purposes.

---

## 🎓 LEARNING OBJECTIVES

### Waxa Aad Ka Baran Karto Mashruucan

#### Backend Development
1. **RESTful API Design** - Sidee loo sameeyo API endpoints
2. **Database Modeling** - Sidee loo qaabeyo database schema
3. **Authentication** - JWT iyo password encryption
4. **CRUD Operations** - Create, Read, Update, Delete
5. **Error Handling** - Sidee loo maaraayo errors
6. **Middleware** - Authentication iyo validation

#### Frontend Development
1. **Flutter Widgets** - Stateful iyo Stateless widgets
2. **State Management** - GetX controller pattern
3. **API Integration** - HTTP requests iyo responses
4. **Navigation** - Routing between screens
5. **Form Validation** - Input validation
6. **Responsive Design** - UI for different screen sizes

#### Full Stack Integration
1. **Client-Server Communication** - HTTP requests
2. **Data Flow** - Frontend ↔ Backend ↔ Database
3. **Authentication Flow** - Login/logout process
4. **Error Handling** - Frontend iyo backend errors

---

## 🎯 ASSIGNMENT QUESTIONS - GUIDE

### Suaalaha Caadiga Ah ee Assignment-ka

#### 1. **Ma sharxi kartaa qaabdhismeedka mashruuca?**
**Jawaabta**: Mashruucan waxa uu leeyahay laba qaybood:
- Backend (Node.js + Express + MongoDB) - Maamulka xogta iyo API
- Frontend (Flutter) - Mobile app macaamiisha iyo maamulayaasha

#### 2. **Sidee loo maarayaa authentication?**
**Jawaabta**: Waxaan isticmaalnaa JWT (JSON Web Tokens):
- Isticmaaluhu wuxuu soo galaa email iyo password
- Backend wuxuu hubiyaa credentials-ka
- Haddii ay saxda yihiin, wuxuu soo celiyaa token
- Token-ka waxaa loo isticmaalaa requests kasta oo soo socda

#### 3. **Maxay yihiin models-ka database-ka?**
**Jawaabta**: Waxaan leenahay shan model:
- User - Isticmaalayaasha
- Product - Alaabta/Cuntada
- Order - Dalabka
- Category - Qaybaha cuntada
- Settings - Settings-ka app-ka

#### 4. **Sidee loo maarayaa cart-ka?**
**Jawaabta**: CartController (GetX) ayaa maamula:
- Ku darista items
- Ka saarida items
- Wax ka beddelida quantity
- Xisaabinta wadarta

#### 5. **Maxay yihiin farqiga customer iyo admin?**
**Jawaabta**:
- Customer: Wuxuu arki karaa alaabta oo sameeyn karaa dalabka
- Admin: Wuxuu maarayn karaa alaabta, dalabka, isticmaalayaasha

---

## 📚 GLOSSARY (ERAYADA MUHIIMKA AH)

- **API** - Application Programming Interface
- **Backend** - Server-side code
- **Frontend** - Client-side code (Mobile app)
- **Database** - Xogta la kaydiyo (MongoDB)
- **Model** - Qaabka xogta database-ka
- **Controller** - Business logic
- **Route** - API endpoint
- **Middleware** - Code that runs before route handler
- **JWT** - JSON Web Token (authentication)
- **CRUD** - Create, Read, Update, Delete
- **State Management** - Maamulka xaaladda app-ka
- **Widget** - UI component in Flutter
- **Schema** - Qaabka database table/collection

---

**Diyaariyay**: Team Project
**Taariikhda**: 2026-02-05  
**Version**: 1.0

---

## 🎉 GUNAANAD

Mashruucan waxa uu ku siinayaa aqoon buuxda oo ku saabsan:
- Full-stack development
- Mobile app development
- Database design
- API development
- Authentication & authorization
- State management
- UI/UX design

**Guul ku jirta barashadaada!** 🚀
