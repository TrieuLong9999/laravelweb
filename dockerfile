# Sử dụng image PHP 8.1 với Apache làm nền tảng
FROM php:8.1-apache

# Cài đặt các dependencies cần thiết cho Laravel (các extension PHP và oniguruma)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    git \
    unzip \
    libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql bcmath mbstring

# Cài đặt Composer (trình quản lý phụ thuộc PHP)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Kích hoạt mod_rewrite của Apache để Laravel hoạt động
RUN a2enmod rewrite

# Đặt thư mục làm việc trong container
WORKDIR /var/www/html

# Sao chép toàn bộ mã nguồn Laravel vào container
COPY . .

# Cài đặt các phụ thuộc của Laravel (composer install)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Cấp quyền cho các thư mục cần thiết (storage, bootstrap/cache)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Mở port 80 cho Apache
EXPOSE 80

# Đặt lại DocumentRoot của Apache để trỏ đến thư mục public của Laravel
RUN sed -i 's|/var/www/html|/var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Khởi động Apache
CMD ["apache2-foreground"]
