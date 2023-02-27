/* youtube-dl-qt is Free Software: You can use, study share
 * and improve it at your will. Specifically you can redistribute
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 * 
 * The original author of this code : Robin de Rooij (https://github.com/rrooij)
 * The original repository of this code : https://github.com/rrooij/youtube-dl-qt 
 */

#include "mediaformat.h"

MediaFormat::MediaFormat(QObject *parent) : QObject{parent}
{

}

QStringList MediaFormat::getFormatId() const
{
    return m_formatId;
}

void MediaFormat::setFormatId(const QStringList &value)
{
    m_formatId = value;
    emit formatIdChanged(value);
}

void MediaFormat::setFormatIdItem(QString value)
{
    m_formatId << value;
}

QStringList MediaFormat::getExtension() const
{
    return m_extension;
}

void MediaFormat::setExtension(const QStringList &value)
{
    m_extension = value;
    emit extensionChanged(value);
}

void MediaFormat::setExtensionItem(QString value)
{
    m_extension << value;
}

QStringList MediaFormat::getResolution() const
{
    return m_resolution;
}

void MediaFormat::setResolution(const QStringList &value)
{
    m_resolution = value;
    emit resolutionChanged(value);
}

void MediaFormat::setResolutionItem(QString value)
{
    m_resolution << value;
}

QStringList MediaFormat::getQuality() const
{
    return m_quality;
}

void MediaFormat::setQuality(const QStringList &value)
{
    m_quality = value;
    emit qualityChanged(value);
}

void MediaFormat::setQualityItem(QString value)
{
    m_quality << value;
}

QStringList MediaFormat::getNote() const
{
    return m_note;
}

void MediaFormat::setNote(const QStringList &value)
{
    m_note = value;
    emit noteChanged(value);
}

void MediaFormat::setNoteItem(QString value)
{
    m_note << value;
}

QStringList MediaFormat::getFormat() const
{
    return m_format;
}

void MediaFormat::setFormat(const QStringList &value)
{
    m_format = value;
    emit formatChanged(value);
}

void MediaFormat::setFormatItem(QString value)
{
    m_format << value;
}

QStringList MediaFormat::getAcodec() const
{
    return m_acodec;
}

void MediaFormat::setAcodec(const QStringList &value)
{
    m_acodec = value;
    emit acodecChanged(value);
}

void MediaFormat::setAcodecItem(QString value)
{
    m_acodec << value;
}

QStringList MediaFormat::getVcodec() const
{
    return m_vcodec;
}

void MediaFormat::setVcodec(const QStringList &value)
{
    m_vcodec = value;
    emit vcodecChanged(value);
}

void MediaFormat::setVcodecItem(QString value)
{
    m_vcodec << value;
}
