<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AstroSSTool</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            background-color: #121016;
            color: #ffffff;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden;
            position: relative;
        }

        /* Floating background particles */
        .particle {
            position: absolute;
            background-color: rgba(180, 100, 255, 0.6);
            border-radius: 50%;
            pointer-events: none;
            animation: float 8s infinite ease-in-out;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px) scale(1); opacity: 0.3; }
            50% { transform: translateY(-20px) scale(1.2); opacity: 0.8; }
        }

        /* Main Card Container */
        .card {
            background: rgba(24, 20, 32, 0.85);
            border: 1px solid rgba(255, 255, 255, 0.05);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.6);
            border-radius: 16px;
            padding: 40px;
            text-align: center;
            width: 480px;
            z-index: 10;
            backdrop-filter: blur(10px);
        }

        .card h1 {
            color: #b464ff;
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 15px;
            letter-spacing: 0.5px;
        }

        .card p {
            color: #9ca3af;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 30px;
        }

        /* Action Buttons */
        .btn-container {
            display: flex;
            justify-content: center;
            gap: 15px;
        }

        .btn {
            background-color: #9333ea;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
            box-shadow: 0 4px 14px rgba(147, 51, 234, 0.4);
        }

        .btn:hover {
            background-color: #a855f7;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(147, 51, 234, 0.6);
        }
    </style>
</head>
<body>

    <!-- Background Star Particles Generator -->
    <script>
        const particleCount = 35;
        for (let i = 0; i < particleCount; i++) {
            const p = document.createElement('div');
            p.classList.add('particle');
            const size = Math.random() * 3 + 1;
            p.style.width = `${size}px`;
            p.style.height = `${size}px`;
            p.style.left = `${Math.random() * 100}vw`;
            p.style.top = `${Math.random() * 100}vh`;
            p.style.animationDuration = `${Math.random() * 6 + 4}s`;
            p.style.animationDelay = `${Math.random() * 5}s`;
            document.body.appendChild(p);
        }
    </script>

    <!-- Center Hub Card -->
    <div class="card">
        <h1>AstroSSTool</h1>
        <p>Advanced forensic read-only moderation suite for detecting cheat signatures, execution history, and anti-forensic tampering on Windows.</p>
        <div class="btn-container">
            <a href="https://github.com/iyedjouamaa-dot/AstroSSTool" target="_blank" class="btn">GitHub Repository</a>
        </div>
    </div>

</body>
</html>
