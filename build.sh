docker pull container-registry.oracle.com/database/enterprise:12.2.0.1

cd ryndin_linux
./build.sh
cd ..

cd ryndin_services_base
./build.sh
cd ..

cd ryndin_add_data_russian
./build.sh
cd ..


cd osa181001
./build.sh
cd ..
