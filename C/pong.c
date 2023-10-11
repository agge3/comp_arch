static int DISPLAY_WIDTH = 800;
static int DISPLAY_HEIGHT = 600;

static int BALL_RADIUS = 10;
static int BALL_VELOCITY = 8;

static int PLAYER_WIDTH = 40;
static int PLAYER_HEIGHT = 60;

void draw_ball()
{
    int ball_xmin = 400;
    int ball_ymin = 300;

    int color = -1; /* white */

    int ball_width_pixel = BALL_RADIUS * 4;
    int ball_xmin_pixel = ball_xmin * 4;
    int ball_height_pixel = BALL_RADIUS * 800 * 4;
    int ball_ymin_pixel = ball_ymin * 800 * 4;

    int display_row = ball_ymin_pixel + frame_buffer;
    ball_height_pixel += frame_buffer;

    ball_row = display_row + ball_xmin_pixel;
    ball_height_pixel += ball_xmin_pixel;

    display_row += ball_width_pixel;

    int bytes_per_display_row = 0x800;
    int color_counter = color;

    int *x_ptr = ball_row;

    while (ball_row != ball_height_pixel) {
        while (x_ptr != display_row) {
            *x_ptr = color;
            x_ptr++;
        }
        ball_row += bytes_per_display_row;
        display_row += bytes_per_display_row;
    }





    int display_row_start_address = frame_buffer + ball_ymin_pixel; /* u 32 bit */
    ball_height_pixel += frame_buffer; /* u 32 bit */

    int ball_row_start_address = display_row_start_address + ball_xmin_pixel; /* u 32 bit */
    ball_height_pixel += ball_xmin_pixel; /* u 32 bit */

    display_row_start_address += ball_xmin_pixel; /* u 32 bit */

    int bytes_per_display_row = 0x800;

    int *x_ptr = ball

    int *x_ptr = 0;


    ball_height_pixel
    while (



    x_ptr += 4;



    if (*y_ptr != *x_ptr) {

    ball_row_start_address += bytes_per_display_row;
    display_row_start_address += bytes_per_display_row;







int main()
{

