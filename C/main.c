int main()
{
    int exit = 10;
    bool flag = true;
    while (flag) {
        process_input();
        process_collisions();
        render();

        if (exit != 10)
            flag = false;
    }
}
