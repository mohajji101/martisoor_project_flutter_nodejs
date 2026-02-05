const dotenv = require('dotenv');
dotenv.config();

const connectDB = require('../src/config/db');
const User = require('../src/models/User');
const bcrypt = require('bcryptjs');

async function main() {
    // simple arg parsing: --email=... --password=... --name=...
    const rawArgs = process.argv.slice(2);
    const args = {};
    rawArgs.forEach((a) => {
        if (a.startsWith('--')) {
            const [k, v] = a.slice(2).split('=');
            args[k] = v;
        }
    });

    const email = args.email || process.env.ADMIN_EMAIL;
    const password = args.password || process.env.ADMIN_PASSWORD || 'admin123';
    const name = args.name || process.env.ADMIN_NAME || 'Admin';

    if (!email) {
        console.error('Provide --email or set ADMIN_EMAIL in .env');
        process.exit(1);
    }

    await connectDB();

    try {
        let user = await User.findOne({ email });
        const hashed = await bcrypt.hash(password, 10);

        if (user) {
            user.name = name;
            user.password = hashed;
            user.role = 'admin';
            await user.save();
            console.log('Updated existing user to admin:', email);
        } else {
            user = await User.create({
                name,
                email,
                password: hashed,
                role: 'admin',
            });
            console.log('Created admin user:', email);
        }
    } catch (err) {
        console.error('Error creating admin:', err);
        process.exit(1);
    }

    process.exit(0);
}

main();
