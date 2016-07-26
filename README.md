# Aplicación Symfony 3 sobre Docker container

Vamos construir la estructura de una aplicación Symfony utilizando unos cuantos contenedores Docker. Sí, lo se, PHP es un lenguaje bastante rudimentario pero le tengo mucho cariño y aún mantengo un par de sitios web que lo utilizan así que aún no lo he dejado.

Todo el código lo podéis encontrar en este repositorio. Si os gusta, nunca viene mal una estrella más en Github :)

## Symfony application
Me aventuraré a probar Symfony3. El proceso para echar a andar una demo es muy sencillo (cómo han cambiado los tiempos!), ahora sólo hace falta descargarse el [instalador](https://symfony.com/download) (para Windows el proceso es un poco distinto)

```
$ sudo curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
$ sudo chmod a+x /usr/local/bin/symfony
```

Y luego echar a andar la magia
```
$ symfony new symfony-on-docker
```

con esto tenemos ya el código fuente necesario para nuestra aplicación

## Dockerfile
El siguiente paso es construir el container sobre el que se ejecutará la aplicación. Nuestro Docker container estará basado en la imagen base de [Phusion.io]( http://phusion.github.io/baseimage-docker/), en otro post explicaré las ventajas que tiene la misma

```
FROM phusion/baseimage
```

Luego, actualizamos el administrador de paquetes e instalamos PHP
```
RUN apt-get update && \
    apt-get install -y php5 php5-common php5-cli \
                       php5-fpm php5-mcrypt php5-mysql php5-apcu \
                       php5-gd php5-imagick php5-curl php5-intl
```

Ejecutamos el servicio PHP y cambiamos el usuario
```
CMD ["php5-fpm", "-F"]
RUN usermod -u 1000 www-data
```

Hasta aquí tenemos un container listo para ejecutar nuestra aplicación. Vamos a decile qué tiene que ejecutar.

Creamos un archivo bash que será el que se ejecutará cuando nuestro container se inicie, lo llamaremos `entrypoint.sh` y de momento contendrá una única instrucción que será la que inicie el servidor integrado que trae Symfony

```
# entrypoint.sh
php bin/console server:start 0.0.0.0:8000
```

Volviendo al Dockerfile, añadimos el archivo creado y le damos los permisos correspondiente que permitirán su ejecución
```
ADD ./entrypoint.sh /init/entrypoint.sh
RUN chmod 700 /init/entrypoint.sh
```

Luego crearemos un directorio para nuestro código en nuestro container `/code` y le diremos a Docker que queremos que este sea un punto de anclaje para un volumen
```
VOLUME /code
WORKDIR /code
```

Antes de terminar vamos a exponer el puerto 8000 que es el que usará nuestra aplicación
```
EXPOSE 8000
```

Finalmente indicamos que el bootstrap de nuestro container será el fichero entrypoint que creamos hace un momento
```
ENTRYPOINT /init/entrypoint.sh
```

Bien, tenemos un Dockerfile completo con las tareas básicas para echar a andar una aplicación S3. A continuación vamos a construir nuestra imagen a partir de la cual podremos ejecutar cualquier contenedor.
```
$ docker build -t docker-on-symfony .
```

Si queréis saber más sobre docker build, [la documentación oficial](https://docs.docker.com/engine/reference/commandline/build/) os dará más luces al respecto

La primera vez que ejecutemos `build` tomará unos minutos debido a que docker tendrá que descargarse la imagen sobre la cual vamos a trabajar, el resultado será algo como:
```
Sending build context to Docker daemon 36.86 MB
Step 1 : FROM phusion/baseimage:0.9.17
0.9.17: Pulling from phusion/baseimage

e9c5e611068d: Downloading [=======>                            ] 10.27 MB/65.79 MB
c29de585b225: Download complete
0b3e3644d782: Download complete
a3ed95caeb02: Download complete
f9cf24c26853: Download complete
ff82d8c50b3d: Downloading [=========>                         ] 3.243 MB/17.47 MB
```

Una vez que tenemos nuestra imagen lista vamos a crear por fin nuestro container.

```
docker run -d -p 80:8000 -v [path/to/project]/symfony-on-docker:/code  symfony-on-docker-image
```

Para resumir, creamos un container basado en la imagen que acabamos de construir. COn el parámetro `-v [path/to/project]/symfony-on-docker:/code` montamos el volumen y con el parámetro `-p 80:8000` mapeamos el puerto 80 de nuestra máquina virtual con el puesto 8000 de nuestro container, así, cuando accedamos a nuestra máquina virtual a través de un navegador (puerto 80) esta nos cargará lo que le devuelva el puerto 8000 de nuestro contenedor

Para ver si nuestro trabajo funciona, primero verificamos que el container esté ejecutándose
```
$ docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                  NAMES
5f07f5045837        symfony-on-docker-image   "/bin/sh -c /init/ent"   9 minutes ago       Up 9 minutes        0.0.0.0:80->8000/tcp   elated_joliot
```

Efectivamente `Up 9 minutes` nos indica que nuestro pequeño está allí. Ahora vamos a probar la aplicación que hemos añadido. Abrimos una ventana de nuestro navegador preferido e intentamos acceder con la [dirección IP de nuestra máquina virtual](http://192.168.99.100/), que por lo general es `192.168.99.100`. Y voilà, deberíais ver algo como lo siguiente

![Aplicación Symfony]()


Si es así, enhorabuena, ya tenemos nuestra aplicación S3 funcionando correctamente.

Espero que os sirva este pequeño tutorial/introducción a Docker. Este maravilloso blog utiliza Disqus para los comentarios así que cualquier duda, consulta, sugerencia o crítica es bienvenida

Muchas gracias por haber llegado hasta aquí. Que tengáis un Happy Coding!
