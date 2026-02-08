# 启动开发数据库服务（PostgreSQL 和 Redis）

Write-Host "正在启动数据库服务...`n" -ForegroundColor Green

docker-compose -f docker-compose.dev.yaml up -d

Write-Host "`n数据库服务已启动！`n" -ForegroundColor Green

Write-Host "PostgreSQL: localhost:5432" -ForegroundColor Cyan
Write-Host "  用户名: postgres" -ForegroundColor White
Write-Host "  密码: difyai123456" -ForegroundColor White
Write-Host "  数据库: dify`n" -ForegroundColor White

Write-Host "Redis: localhost:6379" -ForegroundColor Cyan
Write-Host "  密码: difyai123456`n" -ForegroundColor White

Write-Host "查看日志: docker-compose -f docker-compose.dev.yaml logs -f" -ForegroundColor Yellow
Write-Host "停止服务: docker-compose -f docker-compose.dev.yaml down" -ForegroundColor Yellow
