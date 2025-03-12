#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BATTERY_PATH "/sys/class/power_supply/BATT/capacity"
#define THRESHOLD 20
#define CRITICAL_THRESHOLD 20

int get_battery_level() {
    FILE *file = fopen(BATTERY_PATH, "r");
    if (!file) {
        perror("Failed to open battery file");
        return -1;
    }

    int level;
    fscanf(file, "%d", &level);
    fclose(file);

    return level;
}

void send_alert() {
    system("notify-send 'Battery Low' 'Battery level is below 20%!'");
}

void check_battery() {
    int battery_level = get_battery_level();
    if (battery_level < 0) {
        return;
    }

    if (battery_level <= THRESHOLD) {
        send_alert();
    }
}

int main() {
    check_battery();
    return 0;
}
